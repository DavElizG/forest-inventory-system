import 'package:flutter/material.dart';

/// Sección de captura de coordenadas GPS
class GpsSection extends StatelessWidget {
  final VoidCallback onCaptureGps;
  final bool isCapturing;
  final String? accuracyWarning;
  final Widget latitudField;
  final Widget longitudField;

  const GpsSection({
    super.key,
    required this.onCaptureGps,
    required this.isCapturing,
    this.accuracyWarning,
    required this.latitudField,
    required this.longitudField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título de sección
        Row(
          children: [
            Icon(Icons.my_location, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Coordenadas GPS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Botón capturar GPS
        ElevatedButton.icon(
          onPressed: isCapturing ? null : onCaptureGps,
          icon: isCapturing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.gps_fixed),
          label: Text(isCapturing ? 'Capturando ubicación...' : 'Capturar Ubicación GPS'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),

        // Warning de precisión
        if (accuracyWarning != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    accuracyWarning!,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Campos de coordenadas
        Row(
          children: [
            Expanded(child: latitudField),
            const SizedBox(width: 12),
            Expanded(child: longitudField),
          ],
        ),
      ],
    );
  }
}
