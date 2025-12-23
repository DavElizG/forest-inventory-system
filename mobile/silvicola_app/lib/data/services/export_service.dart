import 'package:dio/dio.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Servicio para exportación de datos en diferentes formatos
class ExportService {
  static ExportService? _instance;
  static ExportService get instance {
    _instance ??= ExportService._internal();
    return _instance!;
  }

  ExportService._internal();

  final ApiService _apiService = ApiService.instance;

  /// Generar nombre descriptivo de archivo con fecha y hora
  String _generateFileName(String prefix, String extension) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd_HHmm');
    final timestamp = dateFormatter.format(now);
    return '${prefix}_$timestamp.$extension';
  }

  /// Obtener resumen de datos disponibles para exportación
  Future<Map<String, dynamic>> getExportSummary() async {
    try {
      final response = await _apiService.get('/api/Export/summary');
      return _apiService.parseResponse(response);
    } catch (e) {
      throw Exception('Error obteniendo resumen de exportación: ${e.toString()}');
    }
  }

  /// Exportar árboles a CSV
  Future<File> exportArbolesToCsv({String? parcelaId}) async {
    try {
      final response = await _apiService.dio.get(
        '/api/Export/arboles/csv',
        queryParameters: parcelaId != null ? {'parcelaId': parcelaId} : null,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      return await _saveFile(response.data, _generateFileName('inventario_arboles', 'csv'));
    } catch (e) {
      throw Exception('Error exportando a CSV: ${e.toString()}');
    }
  }

  /// Exportar árboles a Excel
  Future<File> exportArbolesToExcel({String? parcelaId}) async {
    try {
      final response = await _apiService.dio.get(
        '/api/Export/arboles/excel',
        queryParameters: parcelaId != null ? {'parcelaId': parcelaId} : null,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      return await _saveFile(
        response.data,
        _generateFileName('inventario_arboles', 'xlsx'),
      );
    } catch (e) {
      throw Exception('Error exportando a Excel: ${e.toString()}');
    }
  }

  /// Exportar árboles a KML
  Future<File> exportArbolesToKml({String? parcelaId}) async {
    try {
      final response = await _apiService.dio.get(
        '/api/Export/arboles/kml',
        queryParameters: parcelaId != null ? {'parcelaId': parcelaId} : null,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      return await _saveFile(
        response.data,
        _generateFileName('inventario_arboles', 'kml'),
      );
    } catch (e) {
      throw Exception('Error exportando a KML: ${e.toString()}');
    }
  }

  /// Exportar árboles a KMZ
  Future<File> exportArbolesToKmz({String? parcelaId}) async {
    try {
      final response = await _apiService.dio.get(
        '/api/Export/arboles/kmz',
        queryParameters: parcelaId != null ? {'parcelaId': parcelaId} : null,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      return await _saveFile(
        response.data,
        _generateFileName('inventario_arboles', 'kmz'),
      );
    } catch (e) {
      throw Exception('Error exportando a KMZ: ${e.toString()}');
    }
  }

  /// Exportar parcelas a KMZ
  Future<File> exportParcelasToKmz() async {
    try {
      final response = await _apiService.dio.get(
        '/api/Export/parcelas/kmz',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      return await _saveFile(
        response.data,
        _generateFileName('inventario_parcelas', 'kmz'),
      );
    } catch (e) {
      throw Exception('Error exportando parcelas a KMZ: ${e.toString()}');
    }
  }

  /// Guardar archivo en el sistema de archivos y retornar File
  Future<File> _saveFile(List<int> bytes, String fileName) async {
    try {
      // Obtener directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/exports');
      
      // Crear directorio si no existe
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Guardar archivo
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      print('✅ Archivo guardado: $filePath');
      return file;
    } catch (e) {
      throw Exception('Error guardando archivo: ${e.toString()}');
    }
  }

  /// Obtener directorio de exportaciones
  Future<Directory> getExportsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${directory.path}/exports');
    
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    return downloadsDir;
  }

  /// Listar archivos exportados
  Future<List<FileSystemEntity>> listExportedFiles() async {
    try {
      final dir = await getExportsDirectory();
      return dir.listSync().toList();
    } catch (e) {
      return [];
    }
  }

  /// Eliminar archivo exportado
  Future<void> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error eliminando archivo: ${e.toString()}');
    }
  }
}
