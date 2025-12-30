import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/config/router_config.dart' as routes;
import '../../../core/services/onboarding_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/sync_loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _onboardingService = OnboardingService();
  
  // Keys para los showcases
  final GlobalKey _arbolesKey = GlobalKey();
  final GlobalKey _parcelasKey = GlobalKey();
  final GlobalKey _especiesKey = GlobalKey();
  final GlobalKey _sincronizarKey = GlobalKey();
  final GlobalKey _exportarKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Verificar si debe mostrar el onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final completed = await _onboardingService.isHomeCompleted();
      if (!completed && mounted) {
        ShowCaseWidget.of(context).startShowCase([
          _arbolesKey,
          _parcelasKey,
          _especiesKey,
          _sincronizarKey,
          _exportarKey,
          _settingsKey,
        ]);
        // Marcar como completado después de iniciar
        await _onboardingService.setHomeCompleted();
      }
    });
  }

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
          Showcase(
            key: _settingsKey,
            description: 'Accede a la configuración, tu perfil y cierra sesión desde aquí.',
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  Navigator.pushNamed(context, routes.AppRoutes.settings),
            ),
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
                Showcase(
                  key: _arbolesKey,
                  title: 'Árboles',
                  description: 'Aquí puedes registrar los árboles que encuentres en las parcelas. Mide el diámetro, altura y registra la especie.',
                  child: _buildMenuCard(
                    context,
                    'Árboles',
                    Icons.park,
                    routes.AppRoutes.arbolList,
                    Colors.green,
                  ),
                ),
                Showcase(
                  key: _parcelasKey,
                  title: 'Parcelas',
                  description: 'Crea y gestiona las parcelas del inventario. Cada parcela representa un área específica del bosque.',
                  child: _buildMenuCard(
                    context,
                    'Parcelas',
                    Icons.grid_on,
                    routes.AppRoutes.parcelaList,
                    Colors.blue,
                  ),
                ),
                Showcase(
                  key: _especiesKey,
                  title: 'Especies',
                  description: 'Consulta el catálogo de especies forestales disponibles para clasificar los árboles.',
                  child: _buildMenuCard(
                    context,
                    'Especies',
                    Icons.eco,
                    routes.AppRoutes.especieList,
                    Colors.teal,
                  ),
                ),
                Showcase(
                  key: _sincronizarKey,
                  title: 'Sincronizar',
                  description: 'Sincroniza tus datos locales con el servidor cuando tengas conexión a internet.',
                  child: _buildMenuCard(
                    context,
                    'Sincronizar',
                    Icons.sync,
                    routes.AppRoutes.sync,
                    Colors.orange,
                  ),
                ),
                Showcase(
                  key: _exportarKey,
                  title: 'Exportar',
                  description: 'Exporta tus datos en diferentes formatos: CSV, Excel o KML/KMZ para Google Earth.',
                  child: _buildMenuCard(
                    context,
                    'Exportar',
                    Icons.download,
                    routes.AppRoutes.export,
                    Colors.purple,
                  ),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FAB principal grande - Agregar Árbol (acción más importante)
          FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, routes.AppRoutes.arbolForm),
            backgroundColor: Colors.green[700],
            icon: const Icon(Icons.add, size: 32),
            label: const Text(
              'AGREGAR ÁRBOL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            heroTag: 'addTree',
          ),
          const SizedBox(height: 12),
          // Menú de acciones rápidas
          FloatingActionButton(
            onPressed: _showQuickActionsMenu,
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.apps),
            heroTag: 'menu',
          ),
        ],
      ),
    );
  }

  /// Mostrar menú de acciones rápidas
  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: const Text('Agregar Árbol'),
              subtitle: const Text('Registro rápido de árbol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.arbolForm);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.sync, color: Colors.white),
              ),
              title: const Text('Sincronizar'),
              subtitle: const Text('Actualizar datos con servidor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.sync);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.grid_on, color: Colors.white),
              ),
              title: const Text('Parcelas'),
              subtitle: const Text('Gestionar áreas de inventario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.parcelaList);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.eco, color: Colors.white),
              ),
              title: const Text('Especies'),
              subtitle: const Text('Catálogo de especies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.especieList);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.download, color: Colors.white),
              ),
              title: const Text('Exportar'),
              subtitle: const Text('Descargar datos en Excel/KML'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.export);
              },
            ),
          ],
        ),
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
