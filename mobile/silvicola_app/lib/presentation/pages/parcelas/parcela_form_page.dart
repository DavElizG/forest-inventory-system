import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../providers/parcela_provider.dart';
import '../../../core/utils/error_helper.dart';
import '../../../data/local/local_database.dart';
import '../../../data/services/sync_service.dart';

class ParcelaFormPage extends StatefulWidget {
  final Map<String, dynamic>? parcela;

  const ParcelaFormPage({super.key, this.parcela});

  @override
  State<ParcelaFormPage> createState() => _ParcelaFormPageState();
}

class _ParcelaFormPageState extends State<ParcelaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  bool _isLoading = false;
  bool _isCapturingLocation = false;
  String? _locationAccuracyWarning;
  bool _isHectares = true; // true = hectáreas, false = m²
  double? _areaEnM2; // Para mostrar la conversión

  late final LocationService _locationService;
  final _localDB = LocalDatabase.instance;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    
    // Agregar listener para calcular conversión automática
    _areaController.addListener(_calcularConversion);

    // Si es edición, cargar datos
    if (widget.parcela != null) {
      _codigoController.text = widget.parcela!['codigo'] ?? '';
      _nombreController.text = widget.parcela!['nombre'] ?? '';
      _descripcionController.text = widget.parcela!['descripcion'] ?? '';
      _areaController.text = widget.parcela!['area']?.toString() ?? '';
      _latitudController.text = widget.parcela!['latitud']?.toString() ?? '';
      _longitudController.text = widget.parcela!['longitud']?.toString() ?? '';
    }
  }
  
  void _calcularConversion() {
    final texto = _areaController.text;
    if (texto.isEmpty) {
      setState(() => _areaEnM2 = null);
      return;
    }
    
    final valor = double.tryParse(texto);
    if (valor != null) {
      setState(() {
        if (_isHectares) {
          // Convertir hectáreas a m² (1 ha = 10,000 m²)
          _areaEnM2 = valor * 10000;
        } else {
          // Convertir m² a hectáreas
          _areaEnM2 = valor / 10000;
        }
      });
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
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
      final now = DateTime.now().toIso8601String();
      final isEdit = widget.parcela != null;
      
      // Convertir el área a hectáreas si está en m²
      double areaEnHectareas = double.tryParse(_areaController.text) ?? 0.0;
      if (!_isHectares) {
        // Convertir de m² a hectáreas
        areaEnHectareas = areaEnHectareas / 10000;
      }
      
      final parcelaData = {
        'id': widget.parcela?['id'] ?? const Uuid().v4(),
        'codigo': _codigoController.text.trim(),
        'nombre': _nombreController.text.trim().isEmpty 
            ? _codigoController.text.trim() 
            : _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'area': areaEnHectareas, // Siempre guardamos en hectáreas
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
        'sincronizado': 0,
        'fecha_creacion': widget.parcela?['fecha_creacion'] ?? now,
        'fecha_actualizacion': now,
      };

      if (isEdit) {
        await _localDB.updateParcela(parcelaData['id'], parcelaData);
        if (mounted) {
          ErrorHelper.showSuccess(context, 'Parcela actualizada correctamente');
          // Refrescar lista y contadores
          context.read<ParcelaProvider>().fetchParcelas();
          final syncService = context.read<SyncService>();
          await syncService.updatePendingCounts();
          
          // Si hay internet, sincronizar automáticamente
          final connectivity = context.read<ConnectivityService>();
          if (connectivity.isOnline) {
            await syncService.syncAll();
          }
          
          Navigator.pop(context, true);
        }
      } else {
        await _localDB.insertParcela(parcelaData);
        if (mounted) {
          ErrorHelper.showSuccess(context, 'Parcela creada correctamente');
          // Refrescar lista y contadores
          context.read<ParcelaProvider>().fetchParcelas();
          final syncService = context.read<SyncService>();
          await syncService.updatePendingCounts();
          
          // Si hay internet, sincronizar automáticamente
          final connectivity = context.read<ConnectivityService>();
          if (connectivity.isOnline) {
            await syncService.syncAll();
          }
          
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(context, 'Error al guardar parcela: $e');
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

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Nombre descriptivo de la parcela',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

                // Área con selector de unidades
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _areaController,
                        decoration: InputDecoration(
                          labelText: 'Área *',
                          hintText: _isHectares ? 'Ej: 2.5' : 'Ej: 25000',
                          prefixIcon: const Icon(Icons.straighten),
                          suffixText: _isHectares ? 'ha' : 'm²',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          helperText: _areaEnM2 != null
                              ? (_isHectares
                                  ? '≈ ${_areaEnM2!.toStringAsFixed(2)} m²'
                                  : '≈ ${_areaEnM2!.toStringAsFixed(4)} ha')
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El área es requerida';
                          }
                          final numero = double.tryParse(value);
                          if (numero == null || numero <= 0) {
                            return 'Ingresa un área válida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!_isHectares) {
                                    setState(() {
                                      _isHectares = true;
                                      _calcularConversion();
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isHectares ? Colors.green[700] : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: Text(
                                      'ha',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isHectares ? Colors.white : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, color: Colors.grey[400]),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (_isHectares) {
                                    setState(() {
                                      _isHectares = false;
                                      _calcularConversion();
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isHectares ? Colors.green[700] : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: Text(
                                      'm²',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !_isHectares ? Colors.white : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

                        // Latitud y Longitud en fila
                        Row(
                          children: [
                            // Latitud
                            Expanded(
                              child: TextFormField(
                                controller: _latitudController,
                                decoration: InputDecoration(
                                  labelText: 'Latitud *',
                                  hintText: 'Ej: 14.123',
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
                                    return 'Requerido';
                                  }
                                  final lat = double.tryParse(value);
                                  if (lat == null || lat < -90 || lat > 90) {
                                    return 'Inválido';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Longitud
                            Expanded(
                              child: TextFormField(
                                controller: _longitudController,
                                decoration: InputDecoration(
                                  labelText: 'Longitud *',
                                  hintText: 'Ej: -89.123',
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
                                    return 'Requerido';
                                  }
                                  final lon = double.tryParse(value);
                                  if (lon == null || lon < -180 || lon > 180) {
                                    return 'Inválido';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ],
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

