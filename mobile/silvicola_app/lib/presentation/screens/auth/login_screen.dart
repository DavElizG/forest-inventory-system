import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../../core/utils/error_helper.dart';
import '../../../core/widgets/connectivity_widgets.dart';
import '../../../data/services/sync_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/especie_provider.dart';
import '../../providers/parcela_provider.dart';
import '../../providers/arbol_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Sincronizar datos del servidor y recargar providers
  Future<void> _syncAndRefreshData() async {
    print('[LOGIN] 🔧 Entrando a _syncAndRefreshData()');
    try {
      // 1. Ejecutar sincronización (descarga datos del servidor)
      print('[LOGIN] 📡 Obteniendo SyncService...');
      final syncService = context.read<SyncService>();
      print('[LOGIN] 📥 Llamando a syncAll()...');
      await syncService.syncAll();
      print('[LOGIN] ✅ syncAll() completado');
      
      // 2. Recargar todos los providers
      if (mounted) {
        print('[LOGIN] 🔄 Recargando providers...');
        await Future.wait([
          context.read<EspecieProvider>().fetchEspecies(),
          context.read<ParcelaProvider>().fetchParcelas(),
          context.read<ArbolProvider>().fetchArboles(),
        ]);
        print('[LOGIN] ✅ Providers recargados');
      }
    } catch (e) {
      print('[LOGIN] ❌ Error en sync inicial: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      print('[LOGIN] 🔄 Iniciando sincronización de datos...');
      // Sincronizar datos del servidor y recargar listas
      await _syncAndRefreshData();
      print('[LOGIN] ✅ Sincronización completada');
      
      // Verificar si hay una ruta pendiente
      final pendingRoute = authProvider.consumePendingRoute();
      final targetRoute = pendingRoute ?? routes.AppRoutes.home;
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(targetRoute);
      }
    } else {
      ErrorHelper.showError(
        context,
        authProvider.errorMessage ?? 'Error al iniciar sesión',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nature,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Silvícola',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Inventario Forestal'),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                
                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: const Text('Mantener sesión activa'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Connectivity Indicator
                const ConnectivityIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
