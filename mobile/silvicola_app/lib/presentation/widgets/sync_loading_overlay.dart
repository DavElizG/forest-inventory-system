import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/sync_service.dart';

/// Overlay que muestra el estado de sincronización en curso
class SyncLoadingOverlay extends StatelessWidget {
  const SyncLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        if (!syncService.isSyncing) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 4,
            color: Colors.blue.shade700,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sincronizando...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (syncService.totalPending > 0)
                            Text(
                              '${syncService.totalPending} registros pendientes',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.cloud_upload,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
