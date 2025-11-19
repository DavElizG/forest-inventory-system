import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/location_service.dart';
import '../../providers/parcela_provider.dart';
import '../../../core/utils/error_helper.dart';

class ParcelaFormPage extends StatefulWidget {
  final Map<String, dynamic>? parcela;

  const ParcelaFormPage({super.key, this.parcela});

  @override
  State<ParcelaFormPage> createState() => _ParcelaFormPageState();
}

class _ParcelaFormPageState extends State<ParcelaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  bool _isLoading = false;
  bool _isCapturingLocation = false;
  String? _locationAccuracyWarning;

  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    // Si es edición, cargar datos
    if (widget.parcela != null) {
      _codigoController.text = widget.parcela!['codigo'] ?? '';
      _descripcionController.text = widget.parcela!['descripcion'] ?? '';
      _areaController.text = widget.parcela!['area']?.toString() ?? '';
      _latitudController.text = widget.parcela!['latitud']?.toString() ?? '';
      _longitudController.text = widget.parcela!['longitud']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    _areaController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _captureGPS() async {
    setState(() {
      _isCapturingLocation = true;
      _locationAccuracyWarning = null;
    });

    try {
      // Verificar y solicitar permisos
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permisos de Ubicación'),
              content: const Text(
                'Esta aplicación necesita acceso a tu ubicación para capturar '
                'las coordenadas GPS de las parcelas. Por favor, habilita los '
                'permisos de ubicación en la configuración.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Abrir Configuración'),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            await _locationService.openAppSettings();
          }
        }
        return;
      }

      // Capturar ubicación con feedback de progreso
      Position? position = await _locationService.getCurrentLocationWithProgress(
        onProgress: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      );

      if (position != null) {
        setState(() {
          _latitudController.text = position.latitude.toStringAsFixed(6);
          _longitudController.text = position.longitude.toStringAsFixed(6);

          // Advertir si la precisión es baja (>100 metros)
          if (position.accuracy > 100) {
            _locationAccuracyWarning =
                'Precisión baja: ±${position.accuracy.toStringAsFixed(0)}m. '
                'Considera ajustar manualmente las coordenadas.';
          }
        });

        if (mounted) {
          ErrorHelper.showSuccess(
            context,
            'Ubicación capturada exitosamente',
          );
        }
      } else {
        if (mounted) {
          ErrorHelper.showError(
            context,
            'No se pudo obtener la ubicación. Intenta nuevamente o ingresa '
            'las coordenadas manualmente.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(
          context,
          'Error al capturar ubicación: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
      }
    }
  }

  Future<void> _saveParcela() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que haya coordenadas
    if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      ErrorHelper.showError(
        context,
        'Debes capturar o ingresar las coordenadas GPS',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final parcelaData = {
        'id': widget.parcela?['id'] ?? const Uuid().v4(),
        'codigo': _codigoController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'area': double.tryParse(_areaController.text) ?? 0.0,
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
        'activo': 1,
        'sincronizado': 0,
        'fechaCreacion': widget.parcela?['fechaCreacion'] ??
            DateTime.now().toIso8601String(),
        'fechaModificacion': DateTime.now().toIso8601String(),
      };

      final parcelaProvider = context.read<ParcelaProvider>();
      final success = await parcelaProvider.saveParcela(parcelaData);

      if (success && mounted) {
        ErrorHelper.showSuccess(
          context,
          widget.parcela == null
              ? 'Parcela creada exitosamente'
              : 'Parcela actualizada exitosamente',
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ErrorHelper.showError(
          context,
          parcelaProvider.errorMessage ?? 'Error al guardar la parcela',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(
          context,
          'Error al guardar: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.parcela != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Parcela' : 'Nueva Parcela'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Código de parcela
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código de Parcela *',
                    hintText: 'Ej: P001',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código es requerido';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción de la parcela',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Área
                TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'Área (ha)',
                    hintText: 'Ej: 2.5',
                    prefixIcon: const Icon(Icons.straighten),
                    suffixText: 'ha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // Sección de GPS
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Coordenadas GPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botón de captura GPS
                        ElevatedButton.icon(
                          onPressed: _isCapturingLocation ? null : _captureGPS,
                          icon: _isCapturingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            _isCapturingLocation
                                ? 'Capturando ubicación...'
                                : 'Capturar Ubicación Actual',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        // Advertencia de precisión
                        if (_locationAccuracyWarning != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _locationAccuracyWarning!,
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'O ingresa las coordenadas manualmente:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Latitud
                        TextFormField(
                          controller: _latitudController,
                          decoration: InputDecoration(
                            labelText: 'Latitud *',
                            hintText: 'Ej: 14.123456',
                            prefixIcon: const Icon(Icons.pin_drop),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La latitud es requerida';
                            }
                            final lat = double.tryParse(value);
                            if (lat == null || lat < -90 || lat > 90) {
                              return 'Latitud inválida (-90 a 90)';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Longitud
                        TextFormField(
                          controller: _longitudController,
                          decoration: InputDecoration(
                            labelText: 'Longitud *',
                            hintText: 'Ej: -89.123456',
                            prefixIcon: const Icon(Icons.pin_drop),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La longitud es requerida';
                            }
                            final lon = double.tryParse(value);
                            if (lon == null || lon < -180 || lon > 180) {
                              return 'Longitud inválida (-180 a 180)';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón guardar
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveParcela,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isEdit ? 'Actualizar Parcela' : 'Guardar Parcela',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

