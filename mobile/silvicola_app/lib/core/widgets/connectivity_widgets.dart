import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../../data/services/sync_service.dart';

/// Widget que muestra un banner global con el estado de conectividad y sincronización
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivity, sync, child) {
        // Si está online y no está sincronizando, no mostrar banner
        if (connectivity.isOnline && !sync.isSyncing && sync.totalPending == 0) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        IconData icon;
        String message;

        if (sync.isSyncing) {
          backgroundColor = Colors.blue[700]!;
          icon = Icons.sync;
          message = 'Sincronizando datos...';
        } else if (!connectivity.isOnline) {
          backgroundColor = Colors.orange[700]!;
          icon = Icons.cloud_off;
          final pendingCount = sync.totalPending;
          message = pendingCount > 0
              ? 'Sin conexión - $pendingCount registros pendientes'
              : 'Sin conexión a Internet';
        } else if (sync.totalPending > 0) {
          backgroundColor = Colors.amber[700]!;
          icon = Icons.cloud_upload;
          message = '${sync.totalPending} registros pendientes de sincronizar';
        } else {
          return const SizedBox.shrink();
        }

        return Material(
          color: backgroundColor,
          elevation: 4,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (sync.isSyncing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget flotante más pequeño que muestra el estado de conectividad
class ConnectivityIndicator extends StatelessWidget {
  final bool showLabel;
  
  const ConnectivityIndicator({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivity, sync, child) {
        final isOnline = connectivity.isOnline;
        final isSyncing = sync.isSyncing;
        final hasPending = sync.totalPending > 0;

        Color color;
        IconData icon;
        String label;

        if (isSyncing) {
          color = Colors.blue;
          icon = Icons.sync;
          label = 'Sincronizando';
        } else if (!isOnline) {
          color = Colors.red;
          icon = Icons.cloud_off;
          label = 'Offline';
        } else if (hasPending) {
          color = Colors.orange;
          icon = Icons.cloud_upload;
          label = '${sync.totalPending} pendientes';
        } else {
          color = Colors.green;
          icon = Icons.cloud_done;
          label = 'Online';
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(icon, color: color, size: 20),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Botón de sincronización manual
class SyncButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const SyncButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivity, sync, child) {
        final canSync = connectivity.isOnline && !sync.isSyncing && sync.totalPending > 0;
        
        return IconButton(
          onPressed: canSync ? onPressed : null,
          icon: sync.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.cloud_upload,
                  color: canSync ? Colors.blue : Colors.grey,
                ),
          tooltip: sync.isSyncing
              ? 'Sincronizando...'
              : !connectivity.isOnline
                  ? 'Sin conexión a Internet'
                  : sync.totalPending == 0
                      ? 'Todo sincronizado'
                      : 'Sincronizar ${sync.totalPending} registros',
        );
      },
    );
  }
}
