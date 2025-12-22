import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/connectivity_service.dart';
import '../../data/services/sync_service.dart';

/// Banner que muestra el estado de conectividad y datos pendientes
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivityService, syncService, child) {
        // No mostrar nada si está online y sincronizando (el overlay lo muestra)
        if (connectivityService.isOnline && syncService.isSyncing) {
          return const SizedBox.shrink();
        }

        // Mostrar banner offline si no hay conexión
        if (!connectivityService.isOnline) {
          return _buildBanner(
            context: context,
            icon: Icons.cloud_off,
            color: Colors.orange.shade700,
            title: 'Sin conexión',
            subtitle: syncService.totalPending > 0
                ? '${syncService.totalPending} cambios sin sincronizar'
                : 'Trabajando sin conexión',
            onTap: () => Navigator.pushNamed(context, '/sync'),
          );
        }

        // Mostrar banner de pendientes si hay datos sin sincronizar
        if (syncService.totalPending > 0) {
          return _buildBanner(
            context: context,
            icon: Icons.cloud_queue,
            color: Colors.blue.shade700,
            title: 'Datos pendientes',
            subtitle: '${syncService.totalPending} registros sin sincronizar',
            onTap: () => Navigator.pushNamed(context, '/sync'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      elevation: 2,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
