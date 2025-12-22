import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/arboles/arbol_list_screen.dart';
import '../../presentation/screens/arboles/arbol_form_screen.dart';
import '../../presentation/screens/arboles/arbol_detail_screen.dart';
import '../../presentation/screens/parcelas/parcela_list_screen.dart';
import '../../presentation/screens/parcelas/parcela_form_screen.dart';
import '../../presentation/screens/especies/especie_list_screen.dart';
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
  static const String arbolDetail = '/arboles/detail';
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
        arbolList: (context) => const AuthGuardedRoute(child: ArbolListScreen()),
        arbolForm: (context) => const AuthGuardedRoute(child: ArbolFormScreen()),
        arbolDetail: (context) => const AuthGuardedRoute(child: ArbolDetailScreen()),
        parcelaList: (context) => const AuthGuardedRoute(child: ParcelaListScreen()),
        parcelaForm: (context) => const AuthGuardedRoute(child: ParcelaFormScreen()),
        especieList: (context) => const AuthGuardedRoute(child: EspecieListScreen()),
        sync: (context) => const AuthGuardedRoute(child: SyncScreen()),
        syncPreview: (context) => const AuthGuardedRoute(child: SyncPreviewPage()),
        reportes: (context) => const AuthGuardedRoute(child: ReportesScreen()),
        settings: (context) => const AuthGuardedRoute(child: SettingsScreen()),
      };
}
