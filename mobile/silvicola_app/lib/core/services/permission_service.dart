import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Servicio para gestionar permisos de la aplicación
class PermissionService {
  /// Solicitar permisos esenciales al inicio de la app
  static Future<void> requestInitialPermissions(BuildContext context) async {
    // Lista de permisos necesarios
    final permissions = [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.storage,
    ];

    // Verificar qué permisos faltan
    final permissionsToRequest = <Permission>[];
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        permissionsToRequest.add(permission);
      }
    }

    // Si hay permisos pendientes, mostrar diálogo explicativo
    if (permissionsToRequest.isNotEmpty && context.mounted) {
      await _showPermissionsDialog(context, permissionsToRequest);
    }
  }

  /// Solicitar permisos de ubicación específicamente
  static Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    
    if (status.isDenied) {
      // Intentar con locationWhenInUse
      final whenInUseStatus = await Permission.locationWhenInUse.request();
      return whenInUseStatus.isGranted;
    }
    
    return status.isGranted;
  }

  /// Solicitar permisos de cámara
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Solicitar permisos de almacenamiento
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Verificar si todos los permisos esenciales están concedidos
  static Future<bool> hasAllEssentialPermissions() async {
    final locationStatus = await Permission.location.status;
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;

    return locationStatus.isGranted && 
           cameraStatus.isGranted && 
           storageStatus.isGranted;
  }

  /// Mostrar diálogo explicando permisos necesarios
  static Future<void> _showPermissionsDialog(
    BuildContext context,
    List<Permission> permissions,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text('Permisos necesarios'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silvícola necesita los siguientes permisos para funcionar correctamente:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              if (permissions.any((p) => 
                  p == Permission.location || 
                  p == Permission.locationWhenInUse))
                _buildPermissionItem(
                  Icons.location_on,
                  'Ubicación',
                  'Para capturar coordenadas GPS de árboles y parcelas',
                ),
              if (permissions.contains(Permission.camera))
                _buildPermissionItem(
                  Icons.camera_alt,
                  'Cámara',
                  'Para tomar fotografías de especies y árboles',
                ),
              if (permissions.contains(Permission.storage))
                _buildPermissionItem(
                  Icons.folder,
                  'Almacenamiento',
                  'Para guardar datos y exportar reportes',
                ),
              const SizedBox(height: 16),
              const Text(
                'Puedes cambiar estos permisos en cualquier momento desde la configuración de la app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conceder permisos'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _requestPermissions(permissions);
    }
  }

  static Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Solicitar múltiples permisos
  static Future<void> _requestPermissions(List<Permission> permissions) async {
    for (final permission in permissions) {
      await permission.request();
    }
  }

  /// Abrir configuración de la app para permisos
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
