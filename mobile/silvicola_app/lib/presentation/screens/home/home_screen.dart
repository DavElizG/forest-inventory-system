import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../../core/utils/error_helper.dart';
import '../../../core/services/connectivity_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/arbol_provider.dart';
import '../../pages/arboles/arbol_form_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar árboles al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArbolProvider>().fetchArboles();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.isNotEmpty) return;

    final arbolProvider = context.read<ArbolProvider>();
    if (arbolProvider.isLoadingMore || !arbolProvider.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0;

    if (currentScroll >= maxScroll - delta) {
      arbolProvider.fetchMoreArboles();
    }
  }

  Future<void> _navegarAFormulario({Map<String, dynamic>? arbol}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArbolFormPage(arbol: arbol),
      ),
    );

    if (resultado == true && mounted) {
      context.read<ArbolProvider>().fetchArboles();
    }
  }

  Future<void> _eliminarArbol(String id) async {
    final confirmar = await ErrorHelper.showConfirmDialog(
      context,
      title: 'Eliminar Árbol',
      message: '¿Estás seguro de que deseas eliminar este árbol?',
      confirmText: 'Eliminar',
      isDangerous: true,
    );

    if (!confirmar) return;

    try {
      await context.read<ArbolProvider>().deleteArbol(id);
      if (mounted) {
        ErrorHelper.showSuccess(context, 'Árbol eliminado correctamente');
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(context, 'Error al eliminar árbol: $e');
      }
    }
  }

  List<Map<String, dynamic>> _filtrarArboles(List<Map<String, dynamic>> arboles) {
    if (_searchQuery.isEmpty) return arboles;
    
    return arboles.where((arbol) {
      final nombreLocal = arbol['observaciones']?.toString().toLowerCase() ?? '';
      final especieNombre = arbol['especieNombre']?.toString().toLowerCase() ?? '';
      final parcelaCodigo = arbol['parcelaCodigo']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return nombreLocal.contains(query) ||
          especieNombre.contains(query) ||
          parcelaCodigo.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final arbolProvider = context.watch<ArbolProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final arbolesFiltrados = _filtrarArboles(arbolProvider.arboles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Silvícola'),
        actions: [
          if (!connectivity.isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange[200]),
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
                hintText: 'Buscar árboles...',
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
      body: arbolProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : arbolesFiltrados.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => context.read<ArbolProvider>().fetchArboles(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: arbolesFiltrados.length + 1,
                    itemBuilder: (context, index) {
                      if (index == arbolesFiltrados.length) {
                        if (arbolProvider.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (!arbolProvider.hasMore && arbolesFiltrados.length > 10) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'No hay más árboles',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final arbol = arbolesFiltrados[index];
                      final sincronizado = arbol['sincronizado'] == 1;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.park, color: Colors.green[700]),
                          ),
                          title: Text(
                            arbol['especieNombre'] ?? 'Sin especie',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (arbol['observaciones'] != null && arbol['observaciones'].toString().isNotEmpty)
                                Text('Observaciones: ${arbol['observaciones']}'),
                              if (arbol['parcelaCodigo'] != null)
                                Text(
                                  'Parcela: ${arbol['parcelaCodigo']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              Text(
                                'Altura: ${arbol['altura'] ?? 'N/A'} m | DAP: ${arbol['diametro'] ?? 'N/A'} cm',
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
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
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
                              if (value == 'editar') {
                                _navegarAFormulario(arbol: arbol);
                              } else if (value == 'eliminar') {
                                _eliminarArbol(arbol['id']);
                              }
                            },
                          ),
                          onTap: () => _navegarAFormulario(arbol: arbol),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarAFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Árbol'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.park, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay árboles registrados'
                : 'No se encontraron árboles',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Presiona el botón + arriba para agregar un árbol'
                : 'Intenta con otra búsqueda',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
