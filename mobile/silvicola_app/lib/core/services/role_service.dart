/// Enum de roles de usuario que coincide con el backend
enum RolUsuario {
  administrador(1, 'Administrador'),
  supervisor(2, 'Supervisor'),
  tecnicoForestal(3, 'Técnico Forestal'),
  consultor(4, 'Consultor');

  final int value;
  final String displayName;

  const RolUsuario(this.value, this.displayName);

  /// Obtener rol desde el valor numérico del backend
  static RolUsuario fromValue(int value) {
    switch (value) {
      case 1:
        return RolUsuario.administrador;
      case 2:
        return RolUsuario.supervisor;
      case 3:
        return RolUsuario.tecnicoForestal;
      case 4:
        return RolUsuario.consultor;
      default:
        throw ArgumentError('Rol no válido: $value');
    }
  }

  /// Obtener rol desde string (para compatibilidad)
  static RolUsuario fromString(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
      case '1':
        return RolUsuario.administrador;
      case 'supervisor':
      case '2':
        return RolUsuario.supervisor;
      case 'técnico forestal':
      case 'tecnicoforestal':
      case 'tecnico forestal':
      case '3':
        return RolUsuario.tecnicoForestal;
      case 'consultor':
      case '4':
        return RolUsuario.consultor;
      default:
        throw ArgumentError('Rol no válido: $rol');
    }
  }
}

/// Permisos que pueden tener los roles
enum Permiso {
  // Gestión de usuarios
  gestionarUsuarios,
  verUsuarios,
  
  // Gestión de parcelas
  crearParcelas,
  editarParcelas,
  eliminarParcelas,
  verParcelas,
  
  // Gestión de árboles
  crearArboles,
  editarArboles,
  eliminarArboles,
  verArboles,
  
  // Gestión de especies
  crearEspecies,
  editarEspecies,
  eliminarEspecies,
  verEspecies,
  
  // Exportar datos
  exportarDatos,
  
  // Sincronización
  sincronizarDatos,
  
  // Reportes
  verReportes,
  generarReportes,
}

/// Servicio para manejar permisos basados en roles
class RoleService {
  /// Mapa de permisos por rol
  static final Map<RolUsuario, Set<Permiso>> _permisosPorRol = {
    RolUsuario.administrador: {
      // Administradores tienen todos los permisos
      ...Permiso.values,
    },
    RolUsuario.supervisor: {
      // Supervisores pueden ver usuarios pero no gestionarlos
      Permiso.verUsuarios,
      
      // Gestión completa de parcelas
      Permiso.crearParcelas,
      Permiso.editarParcelas,
      Permiso.eliminarParcelas,
      Permiso.verParcelas,
      
      // Gestión completa de árboles
      Permiso.crearArboles,
      Permiso.editarArboles,
      Permiso.eliminarArboles,
      Permiso.verArboles,
      
      // Gestión completa de especies
      Permiso.crearEspecies,
      Permiso.editarEspecies,
      Permiso.eliminarEspecies,
      Permiso.verEspecies,
      
      // Exportar y sincronizar
      Permiso.exportarDatos,
      Permiso.sincronizarDatos,
      
      // Reportes
      Permiso.verReportes,
      Permiso.generarReportes,
    },
    RolUsuario.tecnicoForestal: {
      // Ver parcelas
      Permiso.verParcelas,
      
      // Gestión completa de árboles
      Permiso.crearArboles,
      Permiso.editarArboles,
      Permiso.eliminarArboles,
      Permiso.verArboles,
      
      // Ver especies
      Permiso.verEspecies,
      
      // Sincronización
      Permiso.sincronizarDatos,
      
      // Ver reportes
      Permiso.verReportes,
    },
    RolUsuario.consultor: {
      // Solo lectura
      Permiso.verParcelas,
      Permiso.verArboles,
      Permiso.verEspecies,
      Permiso.verReportes,
      Permiso.exportarDatos,
    },
  };

  /// Verificar si un rol tiene un permiso específico
  static bool tienePermiso(RolUsuario rol, Permiso permiso) {
    return _permisosPorRol[rol]?.contains(permiso) ?? false;
  }

  /// Verificar si un rol puede crear registros
  static bool puedeCrear(RolUsuario rol) {
    return tienePermiso(rol, Permiso.crearParcelas) ||
        tienePermiso(rol, Permiso.crearArboles) ||
        tienePermiso(rol, Permiso.crearEspecies);
  }

  /// Verificar si un rol puede editar registros
  static bool puedeEditar(RolUsuario rol) {
    return tienePermiso(rol, Permiso.editarParcelas) ||
        tienePermiso(rol, Permiso.editarArboles) ||
        tienePermiso(rol, Permiso.editarEspecies);
  }

  /// Verificar si un rol puede eliminar registros
  static bool puedeEliminar(RolUsuario rol) {
    return tienePermiso(rol, Permiso.eliminarParcelas) ||
        tienePermiso(rol, Permiso.eliminarArboles) ||
        tienePermiso(rol, Permiso.eliminarEspecies);
  }

  /// Verificar si un rol es administrador
  static bool esAdministrador(RolUsuario rol) {
    return rol == RolUsuario.administrador;
  }

  /// Verificar si un rol es supervisor
  static bool esSupervisor(RolUsuario rol) {
    return rol == RolUsuario.supervisor;
  }

  /// Verificar si un rol es técnico forestal
  static bool esTecnicoForestal(RolUsuario rol) {
    return rol == RolUsuario.tecnicoForestal;
  }

  /// Verificar si un rol es consultor (solo lectura)
  static bool esConsultor(RolUsuario rol) {
    return rol == RolUsuario.consultor;
  }

  /// Obtener lista de permisos de un rol
  static Set<Permiso> obtenerPermisos(RolUsuario rol) {
    return _permisosPorRol[rol] ?? {};
  }
}
