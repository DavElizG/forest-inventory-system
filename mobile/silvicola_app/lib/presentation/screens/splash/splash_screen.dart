import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../../core/services/permission_service.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperar mínimo 2 segundos para mostrar splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // Intentar verificar token existente o auto-login
    bool isAuthenticated = false;
    
    try {
      // Primero intentar verificar token (intenta online, fallback a offline)
      isAuthenticated = await authProvider.verifyToken();
      
      // Si falla, intentar auto-login con credenciales guardadas o datos locales
      if (!isAuthenticated) {
        isAuthenticated = await authProvider.tryAutoLogin();
      }
      
      print('🔐 Estado de autenticación: ${isAuthenticated ? "Autenticado" : "No autenticado"}');
      if (isAuthenticated) {
        print('👤 Usuario: ${authProvider.currentUser?.nombreCompleto}');
      }
    } catch (e) {
      print('⚠️ Error en inicialización: $e');
      // Intentar cargar datos locales como último recurso
      try {
        await authProvider.loadUserFromStorage();
        isAuthenticated = authProvider.isAuthenticated;
      } catch (storageError) {
        print('❌ Error al cargar desde storage: $storageError');
        isAuthenticated = false;
      }
    }

    if (!mounted) return;

    // Solicitar permisos esenciales después de la autenticación
    if (isAuthenticated) {
      try {
        await PermissionService.requestInitialPermissions(context);
      } catch (e) {
        print('⚠️ Error al solicitar permisos: $e');
        // Continuar aunque falle la solicitud de permisos
      }
    }

    if (!mounted) return;

    // Navegar a la pantalla apropiada
    final route = isAuthenticated
        ? routes.AppRoutes.home
        : routes.AppRoutes.login;

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nature,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Silvícola',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Inventario Forestal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
