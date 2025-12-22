/// Enum para los roles de usuario, debe coincidir con RolUsuario.cs en el backend
enum RolUsuario {
  administrador(1, 'Administrador'),
  supervisor(2, 'Supervisor'),
  tecnicoForestal(3, 'Técnico Forestal'),
  consultor(4, 'Consultor');

  final int value;
  final String displayName;

  const RolUsuario(this.value, this.displayName);

  /// Obtener el rol por su valor numérico
  static RolUsuario fromValue(int value) {
    return RolUsuario.values.firstWhere(
      (rol) => rol.value == value,
      orElse: () => RolUsuario.tecnicoForestal,
    );
  }

  /// Obtener el rol por su nombre de display
  static RolUsuario fromDisplayName(String displayName) {
    return RolUsuario.values.firstWhere(
      (rol) => rol.displayName == displayName,
      orElse: () => RolUsuario.tecnicoForestal,
    );
  }

  /// Obtener el texto descriptivo del rol
  static String getDisplayName(int value) {
    return fromValue(value).displayName;
  }

  /// Obtener todos los nombres de display para dropdowns
  static List<String> get displayNames {
    return RolUsuario.values.map((rol) => rol.displayName).toList();
  }

  /// Obtener el valor numérico desde el nombre de display
  static int getValueFromDisplayName(String displayName) {
    return fromDisplayName(displayName).value;
  }
}
