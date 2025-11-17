import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/local/local_database.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/widgets/role_based_widget.dart';
import '../../../core/services/role_service.dart';
import 'especie_form_page.dart';

class EspeciesListPage extends StatefulWidget {
  const EspeciesListPage({super.key});

  @override
  State<EspeciesListPage> createState() => _EspeciesListPageState();
}

class _EspeciesListPageState extends State<EspeciesListPage> {
  final _localDB = LocalDatabase.instance;
  List<Map<String, dynamic>> _especies = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarEspecies();
  }

  Future<void> _cargarEspecies() async {
    setState(() => _isLoading = true);
    
    try {
      final especies = await _localDB.getEspecies();
      setState(() {
        _especies = especies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHelper.showError(context, 'Error cargando especies: $e');
      }
    }
  }

  List<Map<String, dynamic>> get _especiesFiltradas {
    if (_searchQuery.isEmpty) return _especies;
    
    return _especies.where((especie) {
      final nombreCientifico = especie['nombre_cientifico']?.toString().toLowerCase() ?? '';
      final nombreComun = especie['nombre_comun']?.toString().toLowerCase() ?? '';
      final familia = especie['familia']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return nombreCientifico.contains(query) ||
          nombreComun.contains(query) ||
          familia.contains(query);
    }).toList();
  }

  Future<void> _eliminarEspecie(String id) async {
    final confirmar = await ErrorHelper.showConfirmDialog(
      context,
      title: 'Eliminar Especie',
      message: '¿Estás seguro de que deseas eliminar esta especie?',
      confirmText: 'Eliminar',
      isDangerous: true,
    );

    if (!confirmar) return;

    try {
      await _localDB.deleteEspecie(id);
      ErrorHelper.showSuccess(context, 'Especie eliminada correctamente');
      _cargarEspecies();
    } catch (e) {
      ErrorHelper.showError(context, 'Error al eliminar especie: $e');
    }
  }

  Future<void> _navegarAFormulario({Map<String, dynamic>? especie}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EspecieFormPage(
          especie: especie,
          isEdit: especie != null,
        ),
      ),
    );

    if (resultado == true) {
      _cargarEspecies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final canCreate = RoleHelper.hasPermission(context, Permiso.crearEspecies);
    final canEdit = RoleHelper.hasPermission(context, Permiso.editarEspecies);
    final canDelete = RoleHelper.hasPermission(context, Permiso.eliminarEspecies);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Especies Forestales'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar especies...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _especiesFiltradas.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _cargarEspecies,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _especiesFiltradas.length,
                    itemBuilder: (context, index) {
                      final especie = _especiesFiltradas[index];
                      final sincronizado = especie['sincronizado'] == 1;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.eco, color: Colors.green[700]),
                          ),
                          title: Text(
                            especie['nombre_cientifico'] ?? 'Sin nombre',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (especie['nombre_comun'] != null && especie['nombre_comun'].toString().isNotEmpty)
                                Text(especie['nombre_comun']),
                              if (especie['familia'] != null && especie['familia'].toString().isNotEmpty)
                                Text(
                                  'Familia: ${especie['familia']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (!sincronizado)
                                Row(
                                  children: [
                                    Icon(Icons.cloud_off, size: 12, color: Colors.orange[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'No sincronizado',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'ver',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('Ver detalles'),
                                  ],
                                ),
                              ),
                              if (canEdit)
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                              if (canDelete)
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'ver':
                                case 'editar':
                                  _navegarAFormulario(especie: especie);
                                  break;
                                case 'eliminar':
                                  _eliminarEspecie(especie['id']);
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _navegarAFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Especie'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron especies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No hay especies registradas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega una nueva especie para comenzar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
