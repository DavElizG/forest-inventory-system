import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parcela_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/error_helper.dart';
import 'parcela_form_page.dart';

class ParcelaListPage extends StatefulWidget {
  const ParcelaListPage({super.key});

  @override
  State<ParcelaListPage> createState() => _ParcelaListPageState();
}

class _ParcelaListPageState extends State<ParcelaListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar parcelas al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParcelaProvider>().fetchParcelas();
    });
  }

  Future<void> _eliminarParcela(String id) async {
    final confirmar = await ErrorHelper.showConfirmDialog(
      context,
      title: 'Eliminar Parcela',
      message: '¿Estás seguro de que deseas eliminar esta parcela?',
      confirmText: 'Eliminar',
      isDangerous: true,
    );

    if (!confirmar) return;

    try {
      await context.read<ParcelaProvider>().deleteParcela(id);
      if (mounted) {
        ErrorHelper.showSuccess(context, 'Parcela eliminada correctamente');
      }
    } catch (e) {
      if (mounted) {
        ErrorHelper.showError(context, 'Error al eliminar parcela: $e');
      }
    }
  }

  Future<void> _navegarAFormulario({Map<String, dynamic>? parcela}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelaFormPage(parcela: parcela),
      ),
    );

    if (resultado == true && mounted) {
      context.read<ParcelaProvider>().fetchParcelas();
    }
  }

  List<Map<String, dynamic>> _filtrarParcelas(List<Map<String, dynamic>> parcelas) {
    if (_searchQuery.isEmpty) return parcelas;
    
    return parcelas.where((parcela) {
      final codigo = parcela['codigo']?.toString().toLowerCase() ?? '';
      final descripcion = parcela['descripcion']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return codigo.contains(query) || descripcion.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final parcelaProvider = context.watch<ParcelaProvider>();
    
    final parcelasFiltradas = _filtrarParcelas(parcelaProvider.parcelas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcelas'),
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
                hintText: 'Buscar parcelas...',
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
      body: parcelaProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : parcelasFiltradas.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => context.read<ParcelaProvider>().fetchParcelas(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: parcelasFiltradas.length,
                    itemBuilder: (context, index) {
                      final parcela = parcelasFiltradas[index];
                      final sincronizado = parcela['sincronizado'] == 1;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(Icons.grid_on, color: Colors.blue[700]),
                          ),
                          title: Text(
                            parcela['codigo'] ?? 'Sin código',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (parcela['descripcion'] != null && parcela['descripcion'].toString().isNotEmpty)
                                Text(parcela['descripcion']),
                              if (parcela['area'] != null)
                                Text(
                                  'Área: ${parcela['area']} m²',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (parcela['latitud'] != null && parcela['longitud'] != null)
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Lat: ${parcela['latitud']?.toStringAsFixed(6)}, Lon: ${parcela['longitud']?.toStringAsFixed(6)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
                                _navegarAFormulario(parcela: parcela);
                              } else if (value == 'eliminar') {
                                _eliminarParcela(parcela['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarAFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Parcela'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay parcelas registradas'
                : 'No se encontraron parcelas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Agrega una nueva parcela usando el botón +'
                : 'Intenta con otra búsqueda',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
