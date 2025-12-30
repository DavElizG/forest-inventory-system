/// Constantes de rendimiento y configuración
class PerformanceConstants {
  // Paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const Duration cacheValidDuration = Duration(minutes: 5);
  static const int maxCacheSize = 100;
  
  // Sync
  static const int syncBatchSize = 50;
  static const Duration syncDebounce = Duration(seconds: 2);
  
  // Database
  static const int dbBatchSize = 100;
  static const int dbTransactionTimeout = 30; // segundos
  
  // UI
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const double listItemHeight = 72.0;
  
  // Images
  static const int imageCompressionQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int thumbnailSize = 200;
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
