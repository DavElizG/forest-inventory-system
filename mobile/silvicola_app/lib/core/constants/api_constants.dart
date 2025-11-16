class ApiConstants {
  // Base
  static const String baseUrl = '/api';

  // Auth
  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';

  // Arboles
  static const String arboles = '/arboles';
  static String arbolById(int id) => '/arboles/$id';

  // Parcelas
  static const String parcelas = '/parcelas';
  static String parcelaById(int id) => '/parcelas/$id';

  // Especies
  static const String especies = '/especies';

  // Sync
  static const String sync = '/sync';
  static const String syncStatus = '/sync/status';

  // Reportes
  static const String reporteExcel = '/reportes/excel';
  static const String reporteKmz = '/reportes/kmz';
}
