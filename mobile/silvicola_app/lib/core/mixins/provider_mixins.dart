import 'package:flutter/foundation.dart';
import 'dart:async';

/// Mixin para optimizar notificaciones en Providers
/// Reduce llamadas innecesarias a notifyListeners()
mixin OptimizedNotifier on ChangeNotifier {
  bool _isNotifying = false;
  Timer? _debounceTimer;

  /// Notifica listeners solo si no está actualmente notificando
  void safeNotify() {
    if (!_isNotifying) {
      _isNotifying = true;
      notifyListeners();
      Future.microtask(() => _isNotifying = false);
    }
  }

  /// Notifica con debouncing para evitar múltiples notificaciones seguidas
  void debouncedNotify([Duration delay = const Duration(milliseconds: 300)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (!_isNotifying) {
        safeNotify();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Mixin para manejo de estados de carga
mixin LoadingStateMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Ejecutar operación con manejo automático de estado de carga
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    bool showError = true,
    void Function(dynamic error)? onError,
    void Function()? onFinally,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await operation();
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      if (onError != null) {
        onError(e);
      }
      if (showError) rethrow;
      return null;
    } finally {
      if (onFinally != null) {
        onFinally();
      }
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setError(String error) {
    _setError(error);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      // No notificar aquí, se notificará cuando cambie el loading
    }
  }
}

/// Mixin para caché simple
mixin CacheMixin<T> {
  final Map<String, ({T data, DateTime timestamp})> _cache = {};
  Duration get cacheDuration => const Duration(minutes: 5);

  T? getCached(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    final isExpired =
        DateTime.now().difference(cached.timestamp) > cacheDuration;
    if (isExpired) {
      _cache.remove(key);
      return null;
    }

    return cached.data;
  }

  void setCache(String key, T data) {
    _cache[key] = (data: data, timestamp: DateTime.now());
  }

  void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  void cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((_, cached) {
      return now.difference(cached.timestamp) > cacheDuration;
    });
  }
}
