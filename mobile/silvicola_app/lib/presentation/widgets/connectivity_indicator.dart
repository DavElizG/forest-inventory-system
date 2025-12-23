import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/connectivity_service.dart';

/// Widget que muestra el estado de conectividad en tiempo real
/// Verde = Online, Rojo = Offline
class ConnectivityIndicator extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const ConnectivityIndicator({
    Key? key,
    this.showLabel = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        final isOnline = connectivity.isOnline;
        final isSyncing = connectivity.isSyncing;
        
        if (compact) {
          return _buildCompactIndicator(isOnline, isSyncing);
        }
        
        return _buildFullIndicator(context, isOnline, isSyncing);
      },
    );
  }

  Widget _buildCompactIndicator(bool isOnline, bool isSyncing) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.red,
        boxShadow: [
          BoxShadow(
            color: (isOnline ? Colors.green : Colors.red).withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: isSyncing
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildFullIndicator(BuildContext context, bool isOnline, bool isSyncing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isOnline ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSyncing)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOnline ? Colors.green : Colors.red,
                ),
              ),
            )
          else
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: isOnline ? Colors.green : Colors.red,
            ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              isSyncing
                  ? 'Sincronizando...'
                  : (isOnline ? 'En línea' : 'Sin conexión'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget flotante posicionado que puede usarse en cualquier pantalla
class FloatingConnectivityIndicator extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsets margin;

  const FloatingConnectivityIndicator({
    Key? key,
    this.alignment = Alignment.topRight,
    this.margin = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: const ConnectivityIndicator(
          showLabel: false,
          compact: false,
        ),
      ),
    );
  }
}
