import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
// Usar implementaciones completas de pages/ en lugar de stubs de screens/
import '../../presentation/pages/arboles/arbol_list_page.dart';
import '../../presentation/pages/arboles/arbol_form_page.dart';
import '../../presentation/pages/parcelas/parcela_list_page.dart';
import '../../presentation/pages/parcelas/parcela_form_page.dart';
import '../../presentation/pages/especies/especies_list_page.dart';
import '../../presentation/pages/especies/especie_form_page.dart';
import '../../presentation/screens/sync/sync_screen.dart';
import '../../presentation/pages/sync_preview_page.dart';
import '../../presentation/screens/reportes/reportes_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../guards/auth_guard.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String arbolList = '/arboles';
  static const String arbolForm = '/arboles/form';
  static const String parcelaList = '/parcelas';
  static const String parcelaForm = '/parcelas/form';
  static const String especieList = '/especies';
  static const String sync = '/sync';
  static const String syncPreview = '/sync/preview';
  static const String reportes = '/reportes';
  static const String settings = '/settings';

  // Routes map with auth protection
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        home: (context) => const AuthGuardedRoute(child: HomeScreen()),
        arbolList: (context) => const AuthGuardedRoute(child: ArbolListPage()),
        arbolForm: (context) => const AuthGuardedRoute(child: ArbolFormPage()),
        parcelaList: (context) => const AuthGuardedRoute(child: ParcelaListPage()),
        parcelaForm: (context) => const AuthGuardedRoute(child: ParcelaFormPage()),
        especieList: (context) => const AuthGuardedRoute(child: EspeciesListPage()),
        sync: (context) => const AuthGuardedRoute(child: SyncScreen()),
        syncPreview: (context) => const AuthGuardedRoute(child: SyncPreviewPage()),
        reportes: (context) => const AuthGuardedRoute(child: ReportesScreen()),
        settings: (context) => const AuthGuardedRoute(child: SettingsScreen()),
      };
}
