import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/error_helper.dart';
import '../../../data/services/sync_service.dart';
import '../../providers/arbol_provider.dart';
import '../../providers/parcela_provider.dart';
import '../../providers/especie_provider.dart';
import '../../widgets/searchable_dropdown.dart';
import 'widgets/arbol_form_fields.dart';
import 'widgets/gps_section.dart';

/// Formulario optimizado para crear/editar árboles
/// Refactorizado para mejor rendimiento y mantenibilidad
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
  // Keys y controllers
  final _formKey = GlobalKey<FormState>();
  final _parcelaKey = GlobalKey<SearchableDropdownState>();
  final _especieKey = GlobalKey<SearchableDropdownState>();

  late final TextEditingController _fechaMedicionController;
  late final TextEditingController _alturaController;
  late final TextEditingController _alturaComercialController;
  late final TextEditingController _diametroController;
  late final TextEditingController _observacionesController;
  late final TextEditingController _latitudController;
  late final TextEditingController _longitudController;
  late final TextEditingController _numeroArbolController;
  late final LocationService _locationService;
  DateTime _selectedDate = DateTime.now();

  // Estado
  String? _selectedParcelaId;
  String? _selectedEspecieId;
  bool _isLoading = false;
  bool _isCapturingLocation = false;
  String? _locationAccuracyWarning;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _locationService = LocationService();
    _loadData();
  }

  void _initializeControllers() {
    _fechaMedicionController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _alturaController = TextEditingController();
    _alturaComercialController = TextEditingController();
    _diametroController = TextEditingController();
    _observacionesController = TextEditingController();
    _latitudController = TextEditingController();
    _longitudController = TextEditingController();
    _numeroArbolController = TextEditingController(text: '1');
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ParcelaProvider>().fetchParcelas();
      context.read<EspecieProvider>().fetchEspecies();

      // Actualizar número de árbol si es creación con parcela preseleccionada
      if (widget.arbol == null && widget.preSelectedParcelaId != null) {
        _updateNumeroArbol(widget.preSelectedParcelaId!);
      }
    });

    if (widget.arbol != null) {
      final arbol = widget.arbol!;
      _selectedParcelaId = arbol['parcela_id'];
      _selectedEspecieId = arbol['especie_id'];
      _numeroArbolController.text = (arbol['numero_arbol'] ?? 1).toString();
      _fechaMedicionController.text = arbol['fecha_medicion'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      _diametroController.text = arbol['dap']?.toString() ?? '';
      _alturaComercialController.text = arbol['altura_comercial']?.toString() ?? '';
      _alturaController.text = arbol['altura']?.toString() ?? '';
      _observacionesController.text = arbol['observaciones'] ?? '';
      _latitudController.text = arbol['latitud']?.toString() ?? '';
      _longitudController.text = arbol['longitud']?.toString() ?? '';
    } else if (widget.preSelectedParcelaId != null) {
      _selectedParcelaId = widget.preSelectedParcelaId;
    }
  }

  /// Actualizar número de árbol cuando se selecciona una parcela
  Future<void> _updateNumeroArbol(String parcelaId) async {
    final provider = context.read<ArbolProvider>();
    final nextNumero = await provider.getNextNumeroArbol(parcelaId);
    setState(() {
      _numeroArbolController.text = nextNumero.toString();
    });
  }

  @override
  void dispose() {
    _fechaMedicionController.dispose();
    _alturaController.dispose();
    _alturaComercialController.dispose();
    _diametroController.dispose();
    _observacionesController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _numeroArbolController.dispose();
    super.dispose();
  }

  // === SELECTOR DE FECHA ===

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    
    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        _fechaMedicionController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // === MÉTODOS DE GPS ===

  Future<void> _captureGPS() async {
    setState(() {
      _isCapturingLocation = true;
      _locationAccuracyWarning = null;
    });

    try {
      if (!await _requestLocationPermission()) return;

      final position = await _locationService.getCurrentLocationWithProgress(
        onProgress: _showLocationProgress,
      );

      if (position != null && mounted) {
        _updateLocationFields(position);
        ErrorHelper.showSuccess(context, 'Ubicación capturada');
      } else if (mounted) {
        ErrorHelper.showError(context, 'No se pudo obtener la ubicación');
      }
    } catch (e) {
      if (mounted) ErrorHelper.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission && mounted) {
      final shouldOpen = await _showPermissionDialog();
      if (shouldOpen == true) await _locationService.openAppSettings();
    }
    return hasPermission;
  }

  Future<bool?> _showPermissionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permisos de Ubicación'),
        content: const Text(
          'Se necesita acceso a tu ubicación para capturar las coordenadas GPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showLocationProgress(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _updateLocationFields(Position position) {
    setState(() {
      _latitudController.text = position.latitude.toStringAsFixed(6);
      _longitudController.text = position.longitude.toStringAsFixed(6);

      if (position.accuracy > 100) {
        _locationAccuracyWarning =
            'Precisión baja: ±${position.accuracy.toInt()}m';
      }
    });
  }

  // === GUARDAR ===

  Future<void> _saveArbol() async {
    final formValid = _formKey.currentState!.validate();
    final parcelaValid = _parcelaKey.currentState?.validate() == null;
    final especieValid = _especieKey.currentState?.validate() == null;

    if (!formValid || !parcelaValid || !especieValid) return;

    setState(() => _isLoading = true);

    try {
      final alturaComercial = _alturaComercialController.text.trim();
      
      final arbolData = {
        'id': widget.arbol?['id'] ?? const Uuid().v4(),
        'fecha_medicion': _fechaMedicionController.text, // fecha
        'numero_arbol': int.parse(_numeroArbolController.text), // noarb
        'parcela_id': _selectedParcelaId!,
        'especie_id': _selectedEspecieId!, // nc (nombre común)
        'dap': double.parse(_diametroController.text), // dap
        'altura_comercial': alturaComercial.isNotEmpty ? double.parse(alturaComercial) : null, // hc
        'altura': double.parse(_alturaController.text), // ht (altura total)
        'observaciones': _observacionesController.text.trim(), // obs
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
        'activo': 1,
        'sincronizado': 0,
        'fecha_creacion':
            widget.arbol?['fecha_creacion'] ?? DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      final provider = context.read<ArbolProvider>();
      final success = await provider.saveArbol(arbolData);

      if (!mounted) return;

      if (success) {
        // Actualizar contadores de sincronización
        final syncService = context.read<SyncService>();
        await syncService.updatePendingCounts();

        // Si hay internet, sincronizar automáticamente
        final connectivity = context.read<ConnectivityService>();
        if (connectivity.isOnline) {
          await syncService.syncAll();
        }

        ErrorHelper.showSuccess(
          context,
          widget.arbol == null ? 'Árbol registrado' : 'Árbol actualizado',
        );
        Navigator.pop(context, true);
      } else {
        ErrorHelper.showError(
          context,
          provider.errorMessage ?? 'Error al guardar',
        );
      }
    } catch (e) {
      if (mounted) ErrorHelper.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === BUILD ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arbol == null ? 'Nuevo Árbol' : 'Editar Árbol'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Orden según Excel: fecha, noarb, nc, dap, hc, ht, obs
            _buildParcelaDropdown(),
            const SizedBox(height: 16),
            FechaMedicionField(
              controller: _fechaMedicionController,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            _buildNumeroArbolField(),
            const SizedBox(height: 16),
            _buildEspecieDropdown(), // NC (nombre común)
            const SizedBox(height: 24),
            DiametroField(controller: _diametroController), // DAP
            const SizedBox(height: 16),
            AlturaComercialField(controller: _alturaComercialController), // HC
            const SizedBox(height: 16),
            AlturaField(controller: _alturaController), // HT (altura total)
            const SizedBox(height: 16),
            ObservacionesField(controller: _observacionesController), // obs
            const SizedBox(height: 24),
            GpsSection(
              onCaptureGps: _captureGPS,
              isCapturing: _isCapturingLocation,
              accuracyWarning: _locationAccuracyWarning,
              latitudField: LatitudField(controller: _latitudController),
              longitudField: LongitudField(controller: _longitudController),
            ),
            const SizedBox(height: 80), // Espacio para el botón inferior
          ],
        ),
      ),
    );
  }

  Widget _buildParcelaDropdown() {
    return Selector<ParcelaProvider, ({List parcelas, bool isLoading})>(
      selector: (_, provider) => (
        parcelas: provider.parcelas,
        isLoading: provider.isLoading,
      ),
      builder: (_, data, __) => SearchableDropdown(
        key: _parcelaKey,
        label: 'Parcela *',
        hint: 'Selecciona una parcela',
        prefixIcon: Icons.landscape,
        selectedValue: _selectedParcelaId,
        items: data.parcelas.cast<Map<String, dynamic>>(),
        displayText: (p) {
          final cod = p['codigo'] ?? 'Sin código';
          final desc = p['descripcion'];
          return desc != null && desc.toString().isNotEmpty
              ? '$cod - $desc'
              : cod;
        },
        onChanged: (v) {
          setState(() => _selectedParcelaId = v);
          if (v != null && widget.arbol == null) {
            _updateNumeroArbol(v);
          }
        },
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
        isLoading: data.isLoading,
      ),
    );
  }

  Widget _buildNumeroArbolField() {
    return TextFormField(
      controller: _numeroArbolController,
      decoration: InputDecoration(
        labelText: 'Número de Árbol *',
        hintText: 'Automático (editable)',
        prefixIcon: const Icon(Icons.format_list_numbered),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        helperText: 'Se asigna automáticamente, pero puedes cambiarlo',
        helperMaxLines: 2,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El número de árbol es requerido';
        }
        final numero = int.tryParse(value);
        if (numero == null || numero < 1) {
          return 'Debe ser un número mayor a 0';
        }
        return null;
      },
    );
  }

  Widget _buildEspecieDropdown() {
    return Selector<EspecieProvider, ({List especies, bool isLoading})>(
      selector: (_, provider) => (
        especies: provider.especies,
        isLoading: provider.isLoading,
      ),
      builder: (_, data, __) => SearchableDropdown(
        key: _especieKey,
        label: 'Especie *',
        hint: 'Selecciona una especie',
        prefixIcon: Icons.park,
        selectedValue: _selectedEspecieId,
        items: data.especies.cast<Map<String, dynamic>>(),
        displayText: (e) {
          final comun = e['nombre_comun'] ?? e['nombreComun'] ?? '';
          final cientifico =
              e['nombre_cientifico'] ?? e['nombreCientifico'] ?? '';
          return cientifico.isNotEmpty ? '$comun ($cientifico)' : comun;
        },
        onChanged: (v) => setState(() => _selectedEspecieId = v),
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
        isLoading: data.isLoading,
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveArbol,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  widget.arbol == null ? 'REGISTRAR ÁRBOL' : 'ACTUALIZAR ÁRBOL',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
