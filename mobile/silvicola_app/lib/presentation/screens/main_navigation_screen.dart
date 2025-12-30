import 'package:flutter/material.dart';
import '../../../core/config/router_config.dart' as routes;
import 'home/home_screen.dart';
import '../pages/parcelas/parcela_list_page.dart';
import '../pages/especies/especies_list_page.dart';
import 'sync/sync_screen.dart';

/// Pantalla principal con navegación tipo Instagram (barra inferior persistente)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Lista de páginas para la navegación
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const ParcelaListPage(),
      const EspeciesListPage(),
      const SyncScreen(),
    ];
  }

  /// Muestra el menú con opciones adicionales
  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador visual del modal
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.purple[700], size: 28),
              title: const Text('Exportar'),
              subtitle: const Text('Exportar a Excel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.export);
              },
            ),
            ListTile(
              leading: Icon(Icons.assessment, color: Colors.indigo[700], size: 28),
              title: const Text('Reportes'),
              subtitle: const Text('Estadísticas del inventario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.reportes);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey[700], size: 28),
              title: const Text('Configuración'),
              subtitle: const Text('Ajustes y perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        iconSize: 28,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Parcelas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Especies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Sincronizar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Más',
          ),
        ],
        onTap: (index) {
          if (index == 4) {
            _showMoreMenu();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
