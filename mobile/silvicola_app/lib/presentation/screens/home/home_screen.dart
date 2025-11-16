import 'package:flutter/material.dart';

import '../../../core/config/router_config.dart' as routes;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silvícola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, routes.AppRoutes.settings),
          ),
        ],
      ),
      body: Padding(
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
            ),
            _buildMenuCard(
              context,
              'Parcelas',
              Icons.grid_on,
              routes.AppRoutes.parcelaList,
            ),
            _buildMenuCard(
              context,
              'Especies',
              Icons.eco,
              routes.AppRoutes.especieList,
            ),
            _buildMenuCard(
              context,
              'Sincronizar',
              Icons.sync,
              routes.AppRoutes.sync,
            ),
            _buildMenuCard(
              context,
              'Reportes',
              Icons.assessment,
              routes.AppRoutes.reportes,
            ),
            _buildMenuCard(
              context,
              'Configuración',
              Icons.settings,
              routes.AppRoutes.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
