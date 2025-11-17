import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/sync_service.dart';
import '../../data/local/local_database.dart';
import '../../core/services/connectivity_service.dart';

/// Pantalla que muestra los datos pendientes de sincronización con el servidor
class SyncPreviewPage extends StatefulWidget {
  const SyncPreviewPage({super.key});

  @override
  State<SyncPreviewPage> createState() => _SyncPreviewPageState();
}

class _SyncPreviewPageState extends State<SyncPreviewPage> {
  final LocalDatabase _localDB = LocalDatabase.instance;
  
  List<Map<String, dynamic>> _parcelasPendientes = [];
  List<Map<String, dynamic>> _arbolesPendientes = [];
  List<Map<String, dynamic>> _especiesPendientes = [];
  List<Map<String, dynamic>> _fotosPendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosPendientes();
  }

  Future<void> _cargarDatosPendientes() async {
    setState(() => _isLoading = true);
    
    try {
      final parcelas = await _localDB.getParcelas(soloNoSincronizadas: true);
      final arboles = await _localDB.getArboles(soloNoSincronizados: true);
      final especies = await _localDB.getEspecies(soloNoSincronizadas: true);
      final fotos = await _localDB.getFotos(soloNoSincronizadas: true);

      setState(() {
        _parcelasPendientes = parcelas;
        _arbolesPendientes = arboles;
        _especiesPendientes = especies;
        _fotosPendientes = fotos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  Future<void> _sincronizar() async {
    final syncService = context.read<SyncService>();
    final connectivityService = context.read<ConnectivityService>();

    if (!connectivityService.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sin conexión a Internet'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await syncService.syncAll();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success 
                ? '${result.synced} registros sincronizados'
                : '${result.synced} sincronizados, ${result.failed} fallidos',
            ),
            backgroundColor: result.success ? Colors.green : Colors.orange,
          ),
        );
        await _cargarDatosPendientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPendientes = _parcelasPendientes.length +
        _arbolesPendientes.length +
        _especiesPendientes.length +
        _fotosPendientes.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Pendientes'),
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: connectivity.isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivity.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: connectivity.isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalPendientes == 0
              ? _buildEmptyState()
              : _buildPendingList(),
      floatingActionButton: Consumer2<SyncService, ConnectivityService>(
        builder: (context, syncService, connectivity, child) {
          if (totalPendientes == 0) return const SizedBox.shrink();
          final canSync = connectivity.isOnline && !syncService.isSyncing;

          return FloatingActionButton.extended(
            onPressed: canSync ? _sincronizar : null,
            backgroundColor: canSync ? Colors.green : Colors.grey,
            icon: syncService.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload),
            label: Text(
              syncService.isSyncing 
                ? 'Sincronizando...' 
                : 'Sincronizar ($totalPendientes)',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_done, size: 100, color: Colors.green[300]),
          const SizedBox(height: 16),
          const Text(
            'Todos los datos sincronizados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_parcelasPendientes.isNotEmpty)
          _buildCard('Parcelas', _parcelasPendientes.length, Icons.terrain, Colors.green),
        if (_arbolesPendientes.isNotEmpty)
          _buildCard('Árboles', _arbolesPendientes.length, Icons.park, Colors.brown),
        if (_especiesPendientes.isNotEmpty)
          _buildCard('Especies', _especiesPendientes.length, Icons.eco, Colors.teal),
        if (_fotosPendientes.isNotEmpty)
          _buildCard('Fotos', _fotosPendientes.length, Icons.photo, Colors.purple),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCard(String title, int count, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$count pendientes'),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
