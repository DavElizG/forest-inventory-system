import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingService {
  static const _storage = FlutterSecureStorage();
  static const _keyHomeCompleted = 'onboarding_home_completed';
  static const _keyParcelaCompleted = 'onboarding_parcela_completed';
  static const _keyArbolCompleted = 'onboarding_arbol_completed';

  /// Verifica si el usuario ha completado el onboarding de la pantalla principal
  Future<bool> isHomeCompleted() async {
    final value = await _storage.read(key: _keyHomeCompleted);
    return value == 'true';
  }

  /// Marca el onboarding de la pantalla principal como completado
  Future<void> setHomeCompleted() async {
    await _storage.write(key: _keyHomeCompleted, value: 'true');
  }

  /// Verifica si el usuario ha completado el onboarding de parcelas
  Future<bool> isParcelaCompleted() async {
    final value = await _storage.read(key: _keyParcelaCompleted);
    return value == 'true';
  }

  /// Marca el onboarding de parcelas como completado
  Future<void> setParcelaCompleted() async {
    await _storage.write(key: _keyParcelaCompleted, value: 'true');
  }

  /// Verifica si el usuario ha completado el onboarding de árboles
  Future<bool> isArbolCompleted() async {
    final value = await _storage.read(key: _keyArbolCompleted);
    return value == 'true';
  }

  /// Marca el onboarding de árboles como completado
  Future<void> setArbolCompleted() async {
    await _storage.write(key: _keyArbolCompleted, value: 'true');
  }

  /// Reinicia todos los onboardings (útil para testing o settings)
  Future<void> resetAll() async {
    await _storage.delete(key: _keyHomeCompleted);
    await _storage.delete(key: _keyParcelaCompleted);
    await _storage.delete(key: _keyArbolCompleted);
  }
}
