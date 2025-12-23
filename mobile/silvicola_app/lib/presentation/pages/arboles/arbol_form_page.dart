import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/location_service.dart';
import '../../providers/arbol_provider.dart';
import '../../providers/parcela_provider.dart';
import '../../providers/especie_provider.dart';
import '../../../core/utils/error_helper.dart';

class ArbolFormPage extends StatefulWidget {
  final Map<String, dynamic>? arbol;
  final String? preSelectedParcelaId;

  const ArbolFormPage({
    super.key,
    this.arbol,
    this.preSelectedParcelaId,
  });

  @override
  State<ArbolFormPage> createState() => _ArbolFormPageState();
}

class _ArbolFormPageState extends State<ArbolFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _alturaController = TextEditingController();
  final _diametroController = TextEditingController();
  final _nombreLocalController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  String? _selectedParcelaId;
  String? _selectedEspecieId;
  bool _isLoading = false;
  bool _isCapturingLocation = false;
  String? _locationAccuracyWarning;

  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    // Cargar parcelas y especies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParcelaProvider>().fetchParcelas();
      context.read<EspecieProvider>().fetchEspecies();
    });

    // Si es edición, cargar datos
    if (widget.arbol != null) {
      _selectedParcelaId = widget.arbol!['parcelaId'];
      _selectedEspecieId = widget.arbol!['especieId'];
      _alturaController.text = widget.arbol!['altura']?.toString() ?? '';
      _diametroController.text = widget.arbol!['diametro']?.toString() ?? '';
      _nombreLocalController.text = widget.arbol!['nombreLocal'] ?? '';
      _latitudController.text = widget.arbol!['latitud']?.toString() ?? '';
      _longitudController.text = widget.arbol!['longitud']?.toString() ?? '';
    } else if (widget.preSelectedParcelaId != null) {
      _selectedParcelaId = widget.preSelectedParcelaId;
    }
  }

  @override
  void dispose() {
    _alturaController.dispose();
    _diametroController.dispose();
    _nombreLocalController.dispose();
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
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permisos de Ubicación'),
              content: const Text(
                'Esta aplicación necesita acceso a tu ubicación para capturar '
                'las coordenadas GPS de los árboles.',
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

  Future<void> _saveArbol() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedParcelaId == null) {
      ErrorHelper.showError(context, 'Debes seleccionar una parcela');
      return;
    }

    if (_selectedEspecieId == null) {
      ErrorHelper.showError(context, 'Debes seleccionar una especie');
      return;
    }

    if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      ErrorHelper.showError(
        context,
        'Debes capturar o ingresar las coordenadas GPS',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final arbolData = {
        'id': widget.arbol?['id'] ?? const Uuid().v4(),
        'parcelaId': _selectedParcelaId!,
        'especieId': _selectedEspecieId!,
        'altura': double.tryParse(_alturaController.text) ?? 0.0,
        'diametro': double.tryParse(_diametroController.text) ?? 0.0,
        'nombreLocal': _nombreLocalController.text.trim(),
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
        'activo': 1,
        'sincronizado': 0,
        'fechaCreacion': widget.arbol?['fechaCreacion'] ??
            DateTime.now().toIso8601String(),
        'fechaModificacion': DateTime.now().toIso8601String(),
      };

      final arbolProvider = context.read<ArbolProvider>();
      final success = await arbolProvider.saveArbol(arbolData);

      if (success && mounted) {
        ErrorHelper.showSuccess(
          context,
          widget.arbol == null
              ? 'Árbol registrado exitosamente'
              : 'Árbol actualizado exitosamente',
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ErrorHelper.showError(
          context,
          arbolProvider.errorMessage ?? 'Error al guardar el árbol',
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
    final isEdit = widget.arbol != null;
    final parcelaProvider = context.watch<ParcelaProvider>();
    final especieProvider = context.watch<EspecieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Árbol' : 'Nuevo Árbol'),
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
                // Selector de Parcela
                DropdownButtonFormField<String>(
                  initialValue: _selectedParcelaId,
                  decoration: InputDecoration(
                    labelText: 'Parcela *',
                    prefixIcon: const Icon(Icons.landscape),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: parcelaProvider.isLoading
                      ? const Text('Cargando parcelas...')
                      : const Text('Selecciona una parcela'),
                  items: parcelaProvider.parcelas.map((parcela) {
                    final codigo = parcela['codigo'] ?? 'Sin código';
                    final descripcion = parcela['descripcion'];
                    final displayText = descripcion != null && descripcion.toString().isNotEmpty
                        ? '$codigo - $descripcion'
                        : codigo;
                    
                    return DropdownMenuItem(
                      value: parcela['id'] as String,
                      child: Text(
                        displayText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: parcelaProvider.isLoading
                      ? null
                      : (value) {
                          setState(() => _selectedParcelaId = value);
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona una parcela';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de Especie
                DropdownButtonFormField<String>(
                  initialValue: _selectedEspecieId,
                  decoration: InputDecoration(
                    labelText: 'Especie *',
                    prefixIcon: const Icon(Icons.park),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: especieProvider.isLoading
                      ? const Text('Cargando especies...')
                      : const Text('Selecciona una especie'),
                  items: especieProvider.especies.map((especie) {
                    return DropdownMenuItem(
                      value: especie['id'] as String,
                      child: Text(
                        '${especie['nombreComun']} (${especie['nombreCientifico']})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: especieProvider.isLoading
                      ? null
                      : (value) {
                          setState(() => _selectedEspecieId = value);
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona una especie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nombre local
                TextFormField(
                  controller: _nombreLocalController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Local',
                    hintText: 'Nombre común en la región',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Altura
                TextFormField(
                  controller: _alturaController,
                  decoration: InputDecoration(
                    labelText: 'Altura *',
                    hintText: 'Ej: 15.5',
                    prefixIcon: const Icon(Icons.height),
                    suffixText: 'm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La altura es requerida';
                    }
                    final altura = double.tryParse(value);
                    if (altura == null || altura <= 0) {
                      return 'Ingresa una altura válida';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Diámetro
                TextFormField(
                  controller: _diametroController,
                  decoration: InputDecoration(
                    labelText: 'Diámetro (DAP) *',
                    hintText: 'Ej: 45.2',
                    prefixIcon: const Icon(Icons.circle_outlined),
                    suffixText: 'cm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El diámetro es requerido';
                    }
                    final diametro = double.tryParse(value);
                    if (diametro == null || diametro <= 0) {
                      return 'Ingresa un diámetro válido';
                    }
                    return null;
                  },
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

                ElevatedButton(
                  onPressed: _isLoading ? null : _saveArbol,
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
                          isEdit ? 'Actualizar Árbol' : 'Guardar Árbol',
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

