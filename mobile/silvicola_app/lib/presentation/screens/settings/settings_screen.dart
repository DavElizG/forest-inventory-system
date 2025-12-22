import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../../domain/enums/rol_usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Información del usuario
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;
              if (user == null) return const SizedBox.shrink();
              
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Nombre', user.nombreCompleto ?? ''),
                      _buildInfoRow('Email', user.email ?? ''),
                      _buildInfoRow('Rol', user.rol != null ? RolUsuario.getDisplayName(user.rol!) : 'N/A'),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Tema
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('Modo Oscuro'),
                subtitle: const Text('Cambiar tema de la aplicación'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          
          const Divider(),
          
          // Cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          routes.AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}
