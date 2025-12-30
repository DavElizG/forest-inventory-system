import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_helper.dart';

/// Widget reutilizable para captura de coordenadas GPS
/// Incluye validación de permisos, captura de ubicación y visualización de precisión
class GpsFormCapture extends StatefulWidget {
  final TextEditingController latitudController;
  final TextEditingController longitudController;
  final VoidCallback? onLocationCaptured;

  const GpsFormCapture({
    super.key,
    required this.latitudController,
    required this.longitudController,
    this.onLocationCaptured,
  });

  @override
  State<GpsFormCapture> createState() => _GpsFormCaptureState();
}

class _GpsFormCaptureState extends State<GpsFormCapture> {
  final LocationService _locationService = LocationService();
  bool _isCapturing = false;
  String? _accuracyWarning;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Coordenadas GPS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureGPS,
              icon: _isCapturing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.gps_fixed),
              label: Text(_isCapturing ? 'Capturando...' : 'Capturar Ubicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
            if (_accuracyWarning != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _accuracyWarning!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.latitudController,
              decoration: const InputDecoration(
                labelText: 'Latitud *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.south),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                final val = double.tryParse(v);
                if (val == null || val < -90 || val > 90) {
                  return 'Latitud inválida (-90 a 90)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.longitudController,
              decoration: const InputDecoration(
                labelText: 'Longitud *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.east),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                final val = double.tryParse(v);
                if (val == null || val < -180 || val > 180) {
                  return 'Longitud inválida (-180 a 180)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureGPS() async {
    setState(() {
      _isCapturing = true;
      _accuracyWarning = null;
    });

    try {
      if (!await _requestLocationPermission()) return;

      final position = await _locationService.getCurrentLocationWithProgress(
        onProgress: _showProgress,
      );

      if (position != null && mounted) {
        _updateLocationFields(position);
        ErrorHelper.showSuccess(context, 'Ubicación capturada');
        widget.onLocationCaptured?.call();
      } else if (mounted) {
        ErrorHelper.showError(context, 'No se pudo obtener la ubicación');
      }
    } catch (e) {
      if (mounted) ErrorHelper.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission && mounted) {
      final shouldOpen = await _showPermissionDialog();
      if (shouldOpen == true) await _locationService.openAppSettings();
    }
    return hasPermission;
  }

  Future<bool?> _showPermissionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permisos de Ubicación'),
        content: const Text(
          'Se necesita acceso a tu ubicación para capturar las coordenadas GPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showProgress(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _updateLocationFields(Position position) {
    setState(() {
      widget.latitudController.text = position.latitude.toStringAsFixed(6);
      widget.longitudController.text = position.longitude.toStringAsFixed(6);

      if (position.accuracy > 100) {
        _accuracyWarning = 'Precisión baja: ±${position.accuracy.toInt()}m';
      }
    });
  }
}
