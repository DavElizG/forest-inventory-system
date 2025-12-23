import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/local_database.dart';
import '../../../data/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/widgets/role_based_widget.dart';
import '../../../core/services/role_service.dart';

class EspecieFormPage extends StatefulWidget {
  final Map<String, dynamic>? especie;
  final bool isEdit;

  const EspecieFormPage({
    super.key,
    this.especie,
    this.isEdit = false,
  });

  @override
  State<EspecieFormPage> createState() => _EspecieFormPageState();
}

class _EspecieFormPageState extends State<EspecieFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _localDB = LocalDatabase.instance;
  
  late TextEditingController _nombreCientificoController;
  late TextEditingController _nombreComunController;
  late TextEditingController _familiaController;
  late TextEditingController _descripcionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCientificoController = TextEditingController(
      text: widget.especie?['nombre_cientifico'] ?? '',
    );
    _nombreComunController = TextEditingController(
      text: widget.especie?['nombre_comun'] ?? '',
    );
    _familiaController = TextEditingController(
      text: widget.especie?['familia'] ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.especie?['descripcion'] ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCientificoController.dispose();
    _nombreComunController.dispose();
    _familiaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarEspecie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toIso8601String();
      final especieData = {
        'id': widget.especie?['id'] ?? const Uuid().v4(),
        'nombre_cientifico': _nombreCientificoController.text.trim(),
        'nombre_comun': _nombreComunController.text.trim(),
        'familia': _familiaController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'sincronizado': 0,
        'fecha_creacion': widget.especie?['fecha_creacion'] ?? now,
        'fecha_actualizacion': now,
      };

      if (widget.isEdit) {
        await _localDB.updateEspecie(especieData['id'], especieData);
        if (mounted) {
          ErrorHelper.showSuccess(context, 'Especie actualizada correctamente');
          final syncService = context.read<SyncService>();
          await syncService.updatePendingCounts();
          
          // Si hay internet, sincronizar automáticamente
          final connectivity = context.watch<ConnectivityService>();
          if (connectivity.isOnline) {
            await syncService.syncAll();
          }
        }
      } else {
        await _localDB.insertEspecie(especieData);
        if (mounted) {
          ErrorHelper.showSuccess(context, 'Especie creada correctamente');
          final syncService = context.read<SyncService>();
          await syncService.updatePendingCounts();
          
          // Si hay internet, sincronizar automáticamente
          final connectivity = context.watch<ConnectivityService>();
          if (connectivity.isOnline) {
            await syncService.syncAll();
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(context, 'Error al guardar especie: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final canEdit = RoleHelper.hasPermission(context, Permiso.editarEspecies) ||
        RoleHelper.hasPermission(context, Permiso.crearEspecies);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar Especie' : 'Nueva Especie'),
        actions: [
          if (!connectivity.isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  const Text('Offline', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!connectivity.isOnline)
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sin conexión. Los datos se guardarán localmente y se sincronizarán cuando haya Internet.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCientificoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Científico *',
                  hintText: 'Ej: Quercus robur',
                  prefixIcon: Icon(Icons.science),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre científico es requerido';
                  }
                  return null;
                },
                enabled: canEdit && !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreComunController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Común',
                  hintText: 'Ej: Roble',
                  prefixIcon: Icon(Icons.eco),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: canEdit && !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _familiaController,
                decoration: const InputDecoration(
                  labelText: 'Familia',
                  hintText: 'Ej: Fagaceae',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: canEdit && !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Características de la especie',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                enabled: canEdit && !_isLoading,
              ),
              const SizedBox(height: 24),
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _guardarEspecie,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isEdit ? 'Actualizar' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No tienes permisos para editar especies',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
