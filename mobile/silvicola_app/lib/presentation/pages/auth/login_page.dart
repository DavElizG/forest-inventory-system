import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/widgets/connectivity_widgets.dart';
import '../../../data/services/sync_service.dart';
import '../../providers/parcela_provider.dart';
import '../../providers/especie_provider.dart';
import '../../providers/arbol_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.tryAutoLogin();
    
    if (success && mounted) {
      // Sincronizar datos del servidor y recargar listas
      await _syncAndRefreshData();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      // Sincronizar datos del servidor y recargar listas
      await _syncAndRefreshData();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      ErrorHelper.showError(
        context,
        authProvider.errorMessage ?? 'Error al iniciar sesión',
      );
    }
  }

  /// Sincronizar datos y recargar providers
  Future<void> _syncAndRefreshData() async {
    try {
      // 1. Ejecutar sincronización (descarga datos del servidor)
      final syncService = context.read<SyncService>();
      await syncService.syncAll();
      
      // 2. Recargar todos los providers
      if (mounted) {
        await Future.wait([
          context.read<EspecieProvider>().fetchEspecies(),
          context.read<ParcelaProvider>().fetchParcelas(),
          context.read<ArbolProvider>().fetchArboles(),
        ]);
      }
    } catch (e) {
      print('Error en sync inicial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Icon(
                        Icons.park,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      // Título
                      Text(
                        'Silvícola',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Inventario Forestal',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'usuario@ejemplo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El correo es requerido';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es requerida';
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

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                      const SizedBox(height: 16),

                      // Connectivity Indicator
                      const Center(child: ConnectivityIndicator()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Banner de conectividad
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConnectivityBanner(),
          ),
        ],
      ),
    );
  }
}
