import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../providers/auth_provider.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/sync_loading_overlay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silvícola'),
        actions: [
          // Mostrar nombre de usuario
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    authProvider.userName ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, routes.AppRoutes.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Árboles',
                  Icons.park,
                  routes.AppRoutes.arbolList,
                  Colors.green,
                ),
                _buildMenuCard(
                  context,
                  'Parcelas',
                  Icons.grid_on,
                  routes.AppRoutes.parcelaList,
                  Colors.blue,
                ),
                _buildMenuCard(
                  context,
                  'Especies',
                  Icons.eco,
                  routes.AppRoutes.especieList,
                  Colors.teal,
                ),
                _buildMenuCard(
                  context,
                  'Sincronizar',
                  Icons.sync,
                  routes.AppRoutes.sync,
                  Colors.orange,
                ),
                _buildMenuCard(
                  context,
                  'Exportar',
                  Icons.download,
                  routes.AppRoutes.export,
                  Colors.purple,
                ),
                _buildMenuCard(
                  context,
                  'Reportes',
                  Icons.assessment,
                  routes.AppRoutes.reportes,
                  Colors.indigo,
                ),
              ],
            ),
          ),
          // Banner de conectividad
          const ConnectivityBanner(),
          // Overlay de sincronización
          const SyncLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, String route, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
