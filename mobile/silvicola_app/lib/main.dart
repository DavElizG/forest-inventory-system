import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'data/datasources/local/database_helper.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/arbol_provider.dart';
import 'presentation/providers/parcela_provider.dart';
import 'presentation/providers/especie_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializar base de datos local
  await DatabaseHelper.instance.database;
  
  // Inicializar configuración
  await Environment.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ArbolProvider()),
        ChangeNotifierProvider(create: (_) => ParcelaProvider()),
        ChangeNotifierProvider(create: (_) => EspecieProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const SilvicolaApp(),
    ),
  );
}
