import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/router_config.dart' as routes;
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

class SilvicolaApp extends StatelessWidget {
  const SilvicolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Silvícola',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // Localizaciones en español
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'), // Español
          ],
          locale: const Locale('es', 'ES'),
          initialRoute: routes.AppRoutes.splash,
          routes: routes.AppRoutes.routes,
        );
      },
    );
  }
}
