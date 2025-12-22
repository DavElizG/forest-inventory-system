import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización'),
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: connectivity.isOnline ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivity.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SyncService>(
        builder: (context, syncService, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado de sincronización
                _buildSyncStatusCard(context, syncService),
                const SizedBox(height: 16),

                // Resumen de datos pendientes
                _buildPendingDataSummary(context, syncService),
                const SizedBox(height: 16),

                // Botón de sincronización manual
                _buildSyncButton(context, syncService),
                const SizedBox(height: 24),

                // Detalles de sincronización (expandible)
                _buildSyncDetails(context, syncService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context, SyncService syncService) {
    final lastSync = syncService.lastSyncTime;
    final hasError = syncService.lastSyncError != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  syncService.isSyncing
                      ? Icons.sync
                      : hasError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                  color: syncService.isSyncing
                      ? Colors.blue
                      : hasError
                          ? Colors.red
                          : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syncService.isSyncing
                            ? 'Sincronizando...'
                            : hasError
                                ? 'Error en sincronización'
                                : 'Sincronización completa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (lastSync != null && !syncService.isSyncing)
                        Text(
                          'Última sincronización: ${_formatDateTime(lastSync)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncService.lastSyncError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (syncService.isSyncing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDataSummary(BuildContext context, SyncService syncService) {
    final pendingCounts = syncService.pendingCounts;
    final totalPending = syncService.totalPending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Datos pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalPending > 0 ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalPending total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPendingItem(
              'Especies',
              pendingCounts['especies'] ?? 0,
              Icons.eco,
              Colors.green,
            ),
            _buildPendingItem(
              'Parcelas',
              pendingCounts['parcelas'] ?? 0,
              Icons.grid_on,
              Colors.blue,
            ),
            _buildPendingItem(
              'Árboles',
              pendingCounts['arboles'] ?? 0,
              Icons.park,
              Colors.brown,
            ),
            _buildPendingItem(
              'Fotos',
              pendingCounts['fotos'] ?? 0,
              Icons.photo_camera,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingItem(String label, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0 ? color.withOpacity(0.2) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: count > 0 ? color : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, SyncService syncService) {
    final connectivity = context.watch<ConnectivityService>();
    final canSync = connectivity.isOnline && 
                    !syncService.isSyncing && 
                    syncService.totalPending > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canSync ? () => _syncNow(context, syncService) : null,
        icon: Icon(syncService.isSyncing ? Icons.hourglass_empty : Icons.sync),
        label: Text(
          syncService.isSyncing
              ? 'Sincronizando...'
              : !connectivity.isOnline
                  ? 'Sin conexión'
                  : syncService.totalPending == 0
                      ? 'No hay datos pendientes'
                      : 'Sincronizar ahora',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canSync ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSyncDetails(BuildContext context, SyncService syncService) {
    return Card(
      child: ExpansionTile(
        title: const Text('Detalles de sincronización'),
        leading: const Icon(Icons.info_outline),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Sincronización automática', 'Cada 5 minutos'),
                const Divider(),
                _buildDetailRow('Al recuperar conexión', 'Automática'),
                const Divider(),
                _buildDetailRow('Última sincronización', 
                  syncService.lastSyncTime != null 
                    ? _formatDateTime(syncService.lastSyncTime!)
                    : 'Nunca'),
                const Divider(),
                _buildDetailRow('Estado', 
                  syncService.isSyncing 
                    ? 'En progreso' 
                    : 'Inactiva'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  Future<void> _syncNow(BuildContext context, SyncService syncService) async {
    final result = await syncService.syncAll();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
