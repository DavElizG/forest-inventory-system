import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../services/role_service.dart';

/// Widget que muestra u oculta contenido basado en el rol del usuario
class RoleBasedWidget extends StatelessWidget {
  final List<RolUsuario>? allowedRoles;
  final List<Permiso>? requiredPermissions;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const RoleBasedWidget({
    super.key,
    this.allowedRoles,
    this.requiredPermissions,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : assert(
          allowedRoles != null || requiredPermissions != null,
          'Debe especificar al menos allowedRoles o requiredPermissions',
        );

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return showFallback && fallback != null ? fallback! : const SizedBox.shrink();
    }

    try {
      // Obtener rol del usuario actual
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));

      // Verificar si el usuario tiene permiso
      bool hasAccess = false;

      if (allowedRoles != null) {
        hasAccess = allowedRoles!.contains(userRole);
      }

      if (!hasAccess && requiredPermissions != null) {
        hasAccess = requiredPermissions!.every(
          (permission) => RoleService.tienePermiso(userRole, permission),
        );
      }

      if (hasAccess) {
        return child;
      } else {
        return showFallback && fallback != null ? fallback! : const SizedBox.shrink();
      }
    } catch (e) {
      // Si hay error al parsear el rol, no mostrar contenido
      return showFallback && fallback != null ? fallback! : const SizedBox.shrink();
    }
  }
}

/// Widget para ocultar opciones administrativas a usuarios no admin
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: const [RolUsuario.administrador],
      child: child,
      fallback: fallback,
      showFallback: fallback != null,
    );
  }
}

/// Widget para mostrar contenido solo a usuarios que pueden editar
class EditPermissionRequired extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const EditPermissionRequired({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      requiredPermissions: const [Permiso.editarParcelas],
      child: child,
      fallback: fallback,
      showFallback: fallback != null,
    );
  }
}

/// Widget para mostrar contenido solo a usuarios que pueden crear
class CreatePermissionRequired extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const CreatePermissionRequired({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      requiredPermissions: const [Permiso.crearParcelas],
      child: child,
      fallback: fallback,
      showFallback: fallback != null,
    );
  }
}

/// Widget para mostrar contenido solo a usuarios que pueden eliminar
class DeletePermissionRequired extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const DeletePermissionRequired({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      requiredPermissions: const [Permiso.eliminarParcelas],
      child: child,
      fallback: fallback,
      showFallback: fallback != null,
    );
  }
}

/// Helper para verificar permisos en código
class RoleHelper {
  /// Verificar si el usuario actual tiene un permiso específico
  static bool hasPermission(BuildContext context, Permiso permission) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return false;

    try {
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));
      return RoleService.tienePermiso(userRole, permission);
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario actual es administrador
  static bool isAdmin(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return false;

    try {
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));
      return RoleService.esAdministrador(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario actual puede crear
  static bool canCreate(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return false;

    try {
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));
      return RoleService.puedeCrear(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario actual puede editar
  static bool canEdit(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return false;

    try {
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));
      return RoleService.puedeEditar(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario actual puede eliminar
  static bool canDelete(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return false;

    try {
      final userRole = RolUsuario.fromValue(int.parse(currentUser.rol));
      return RoleService.puedeEliminar(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Obtener el rol actual del usuario
  static RolUsuario? getCurrentRole(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return null;

    try {
      return RolUsuario.fromValue(int.parse(currentUser.rol));
    } catch (e) {
      return null;
    }
  }
}
