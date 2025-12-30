 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../../data/services/export_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../providers/parcela_provider.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ExportService _exportService = ExportService.instance;
  bool _isExporting = false;
  String? _selectedParcelaId;
  Map<String, dynamic>? _exportSummary;

  @override
  void initState() {
    super.initState();
    _loadExportSummary();
  }

  Future<void> _loadExportSummary() async {
    try {
      final summary = await _exportService.getExportSummary();
      setState(() {
        _exportSummary = summary;
      });
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _handleExport(BuildContext context, String format) async {
    final connectivity = context.read<ConnectivityService>();
    
    if (!connectivity.isOnline) {
      _showErrorDialog('Sin conexión', 'La exportación requiere conexión a internet.');
      return;
    }

    setState(() => _isExporting = true);

    try {
      late dynamic file;
      
      switch (format.toLowerCase()) {
        case 'csv':
          file = await _exportService.exportArbolesToCsv(parcelaId: _selectedParcelaId);
          break;
        case 'excel':
          file = await _exportService.exportArbolesToExcel(parcelaId: _selectedParcelaId);
          break;
        case 'kml':
          file = await _exportService.exportArbolesToKml(parcelaId: _selectedParcelaId);
          break;
        case 'kmz':
          file = await _exportService.exportArbolesToKmz(parcelaId: _selectedParcelaId);
          break;
        case 'parcelas_kmz':
          file = await _exportService.exportParcelasToKmz();
          break;
        default:
          throw Exception('Formato no soportado');
      }

      if (mounted) {
        _showSuccessDialog(file.path);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error de exportación', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Exportación exitosa'),
          ],
        ),
        content: Text('Archivo guardado en: $filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              OpenFilex.open(filePath);
            },
            child: const Text('Abrir'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(filePath)], text: 'Exportación de datos');
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Datos'),
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
      body: Consumer<ConnectivityService>(
        builder: (context, connectivity, _) {
          if (!connectivity.isOnline) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin conexión a internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'La exportación requiere conexión a internet para obtener los datos del servidor',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return _isExporting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Exportando datos...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen de datos
                      if (_exportSummary != null) _buildSummaryCard(),
                      const SizedBox(height: 16),

                      // Filtro por parcela
                      _buildParcelaFilter(),
                      const SizedBox(height: 24),

                      // Opciones de exportación de árboles
                      const Text(
                        'Exportar Árboles',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildExportOption(
                        'CSV',
                        'Archivo de texto separado por comas',
                        Icons.table_chart,
                        Colors.blue,
                      ),
                      _buildExportOption(
                        'Excel',
                        'Archivo de Microsoft Excel',
                        Icons.grid_on,
                        Colors.green,
                      ),
                      _buildExportOption(
                        'KML',
                        'Google Earth (sin comprimir)',
                        Icons.map,
                        Colors.orange,
                      ),
                      _buildExportOption(
                        'KMZ',
                        'Google Earth (comprimido)',
                        Icons.map,
                        Colors.red,
                      ),
                      const SizedBox(height: 24),

                      // Exportar parcelas
                      const Text(
                        'Exportar Parcelas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildExportOption(
                        'Parcelas_KMZ',
                        'Todas las parcelas en Google Earth',
                        Icons.layers,
                        Colors.purple,
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Especies',
                  _exportSummary!['totalEspecies']?.toString() ?? '0',
                  Icons.eco,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Árboles',
                  _exportSummary!['totalArboles']?.toString() ?? '0',
                  Icons.park,
                  Colors.brown,
                ),
                _buildSummaryItem(
                  'Parcelas',
                  _exportSummary!['totalParcelas']?.toString() ?? '0',
                  Icons.terrain,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildParcelaFilter() {
    return Consumer<ParcelaProvider>(
      builder: (context, parcelaProvider, _) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.filter_list),
            title: const Text('Filtrar por parcela'),
            subtitle: Text(_selectedParcelaId == null ? 'Todas las parcelas' : 'Parcela seleccionada'),
            trailing: DropdownButton<String?>(
              value: _selectedParcelaId,
              hint: const Text('Todas'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todas las parcelas'),
                ),
                ...parcelaProvider.parcelas.map((parcela) {
                  return DropdownMenuItem<String?>(
                    value: parcela['id'] as String?,
                    child: Text(parcela['nombre'] as String? ?? 'Sin nombre'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedParcelaId = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOption(String format, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(format),
        subtitle: Text(description),
        trailing: const Icon(Icons.download),
        onTap: () => _handleExport(context, format),
      ),
    );
  }
}
