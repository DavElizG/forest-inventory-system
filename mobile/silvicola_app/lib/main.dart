import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/local/local_database.dart';
import 'data/services/api_service.dart';
import 'core/services/connectivity_service.dart';
import 'data/services/sync_service.dart';
import 'core/network/api_error_interceptor.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/arbol_provider.dart';
import 'presentation/providers/parcela_provider.dart';
import 'presentation/providers/especie_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno solo en mobile/desktop, no en web
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }

  // Inicializar configuración PRIMERO (necesario para DatabaseHelper)
  await Environment.init();

  // Inicializar base de datos local solo en mobile/desktop DESPUÉS de Environment
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
    // Inicializar nueva base de datos con soporte offline
    await LocalDatabase.instance.database;
  }

  // Inicializar API service
  ApiService.instance.initialize();

  // Crear instancia de Dio para SyncService
  final syncDio = Dio(BaseOptions(
    baseUrl: Environment.apiBaseUrl,
    connectTimeout: Duration(milliseconds: Environment.apiTimeout),
    receiveTimeout: Duration(milliseconds: Environment.apiTimeout),
    headers: {'Content-Type': 'application/json'},
  ));
  syncDio.interceptors.add(ApiErrorInterceptor());

  // Crear instancias de servicios para offline-first
  final connectivityService = ConnectivityService();
  final syncService = SyncService(
    connectivityService: connectivityService,
    dio: syncDio,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Servicio de conectividad
        ChangeNotifierProvider.value(value: connectivityService),
        
        // Servicio de sincronización
        ChangeNotifierProvider.value(value: syncService),
        
        // Auth provider con auto-login
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Providers de entidades
        ChangeNotifierProvider(create: (_) => ArbolProvider()),
        ChangeNotifierProvider(create: (_) => ParcelaProvider()),
        ChangeNotifierProvider(create: (_) => EspecieProvider()),
        ChangeNotifierProvider(create: (context) => SyncProvider(context.read<SyncService>())),
      ],
      child: const SilvicolaApp(),
    ),
  );
}
