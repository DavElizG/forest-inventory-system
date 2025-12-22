import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/providers/auth_provider.dart';

/// Guard que protege rutas que requieren autenticación
class AuthGuard {
  /// Verifica si el usuario está autenticado antes de navegar a una ruta protegida
  static bool checkAuth(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAuthenticated;
  }

  /// Navega a una ruta protegida, redirigiendo al login si no está autenticado
  static Future<void> navigateToProtectedRoute(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      // Guardar la ruta deseada para redirigir después del login
      authProvider.setPendingRoute(routeName);
      
      // Redirigir al login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    // El usuario está autenticado, navegar normalmente
    if (arguments != null) {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  /// Reemplaza la ruta actual con una ruta protegida
  static Future<void> replaceWithProtectedRoute(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      authProvider.setPendingRoute(routeName);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    if (arguments != null) {
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }
}

/// Wrapper para rutas que requieren autenticación
class AuthGuardedRoute extends StatelessWidget {
  final Widget child;
  final String loginRoute;

  const AuthGuardedRoute({
    super.key,
    required this.child,
    this.loginRoute = '/login',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          // Redirigir al login después de construir el widget
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, loginRoute);
          });
          
          // Mostrar loading mientras se redirige
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return child;
      },
    );
  }
}
