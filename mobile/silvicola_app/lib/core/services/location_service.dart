import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio para gestión de geolocalización GPS
/// Proporciona auto-captura de coordenadas con fallback manual
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermission = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermission => _hasPermission;
  
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;
  double? get accuracy => _currentPosition?.accuracy;

  /// Verifica si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    try {
      // Verificar si el servicio está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración.';
        notifyListeners();
        return false;
      }

      // Verificar permisos actuales
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Permisos de ubicación denegados';
          _hasPermission = false;
          notifyListeners();
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Permisos de ubicación denegados permanentemente. Por favor, habilítalos en la configuración.';
        _hasPermission = false;
        notifyListeners();
        return false;
      }

      _hasPermission = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al solicitar permisos: ${e.toString()}';
      _hasPermission = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtiene la ubicación actual con auto-retry
  Future<Position?> getCurrentLocation({int maxRetries = 3}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verificar y solicitar permisos
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Intentar obtener ubicación con reintentos
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );

          // Validar precisión
          if (position.accuracy > 100) {
            // Precisión baja (>100m), advertir pero continuar
            _errorMessage = 'Precisión GPS baja (±${position.accuracy.toStringAsFixed(0)}m). Considera ajustar manualmente.';
          } else {
            _errorMessage = null;
          }

          _currentPosition = position;
          _isLoading = false;
          notifyListeners();
          return position;
        } catch (e) {
          if (attempt == maxRetries) {
            throw e;
          }
          // Esperar antes de reintentar
          await Future.delayed(Duration(seconds: attempt));
        }
      }

      throw Exception('No se pudo obtener ubicación después de $maxRetries intentos');
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: ${e.toString()}';
      _isLoading = false;
      _currentPosition = null;
      notifyListeners();
      return null;
    }
  }

  /// Obtiene ubicación con callback para progreso
  Future<Position?> getCurrentLocationWithProgress({
    required Function(String) onProgress,
  }) async {
    onProgress('Verificando permisos...');
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      return null;
    }

    onProgress('Buscando satélites GPS...');
    Position? position = await getCurrentLocation();
    
    if (position != null) {
      if (position.accuracy <= 20) {
        onProgress('Ubicación obtenida con alta precisión (±${position.accuracy.toStringAsFixed(0)}m)');
      } else if (position.accuracy <= 50) {
        onProgress('Ubicación obtenida con precisión media (±${position.accuracy.toStringAsFixed(0)}m)');
      } else {
        onProgress('Ubicación obtenida con baja precisión (±${position.accuracy.toStringAsFixed(0)}m)');
      }
    }

    return position;
  }

  /// Abre la configuración de permisos de la aplicación
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Limpia el estado y errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia la ubicación actual
  void clearLocation() {
    _currentPosition = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Calcula la distancia entre dos puntos en metros
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Formatea las coordenadas para mostrar
  String formatCoordinates(double? lat, double? lon) {
    if (lat == null || lon == null) return 'No disponible';
    return '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
  }

  /// Valida si las coordenadas están en un rango razonable
  bool validateCoordinates(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
}
