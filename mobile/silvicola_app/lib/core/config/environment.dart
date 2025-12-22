import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static late String apiBaseUrl;
  static late String environment;
  static late int apiTimeout;
  static late String dbName;
  static late int dbVersion;
  static late String? googleMapsApiKey;
  static late int syncIntervalMinutes;
  static late int maxRetryAttempts;

  static Future<void> init() async {
    // En web, usar valores por defecto ya que no cargamos .env
    if (kIsWeb) {
      apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001';
      environment = 'development';
      apiTimeout = 30000;
      dbName = 'silvicola_web_cache';
      dbVersion = 1;
      googleMapsApiKey = null;
      syncIntervalMinutes = 30;
      maxRetryAttempts = 3;
    } else {
      // En mobile/desktop, usar dotenv
      apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5001';
      environment = dotenv.env['ENVIRONMENT'] ?? 'development';
      apiTimeout = int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
      dbName = dotenv.env['DB_NAME'] ?? 'silvicola_local.db';
      dbVersion = int.tryParse(dotenv.env['DB_VERSION'] ?? '1') ?? 1;
      googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      syncIntervalMinutes =
          int.tryParse(dotenv.env['SYNC_INTERVAL_MINUTES'] ?? '30') ?? 30;
      maxRetryAttempts =
          int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '3') ?? 3;
    }
  }

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
