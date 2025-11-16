# Silvícola App - Mobile

Aplicación móvil offline-first para inventario forestal desarrollada en Flutter.

## 📱 Características

- ✅ **Offline-First**: Funciona sin conexión a internet
- 🌲 **Registro de Árboles**: Captura datos de árboles con GPS y cámara
- 📍 **Geolocalización**: Captura automática de coordenadas GPS
- 📸 **Captura de Fotos**: Documentación fotográfica de árboles
- 🔄 **Sincronización**: Sincroniza datos cuando hay conexión
- 📊 **Reportes**: Exporta datos a Excel y KMZ
- 🔐 **Autenticación**: Login seguro con JWT

## 🏗️ Arquitectura

Estructura **Feature-First** con **Clean Architecture**:

```
lib/
├── core/          # Configuración, constantes, utilidades
├── data/          # Modelos, repositorios, datasources
├── domain/        # Entidades, casos de uso
└── presentation/  # Screens, providers, widgets
```

### Capas

- **Domain**: Lógica de negocio pura (entidades, casos de uso)
- **Data**: Implementaciones (repositories, datasources local/remote)
- **Presentation**: UI (screens, widgets, providers)
- **Core**: Utilidades compartidas (config, theme, network)

## 🚀 Comenzar

### Prerrequisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode
- Dispositivo o emulador

### Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/DavElizG/forest-inventory-system.git
   cd forest-inventory-system/mobile/silvicola_app
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env
   # Editar .env con tus valores
   ```

4. **Ejecutar la app**:
   ```bash
   flutter run
   ```

## 📦 Dependencias Principales

| Paquete | Propósito |
|---------|-----------|
| `provider` | State management |
| `sqflite` | Base de datos local SQLite |
| `flutter_secure_storage` | Almacenamiento seguro (tokens) |
| `dio` | Cliente HTTP |
| `geolocator` | Geolocalización GPS |
| `google_maps_flutter` | Mapas |
| `image_picker` | Captura de fotos |
| `excel` | Exportación a Excel |

## 🗂️ Estructura de Datos

### Base de Datos Local (SQLite)

Tablas principales:
- `arboles`: Datos de árboles registrados
- `parcelas`: Parcelas forestales
- `especies`: Catálogo de especies
- `sync_queue`: Cola de sincronización
- `usuarios`: Datos del usuario local

### Sincronización

La app mantiene una cola de cambios pendientes que se sincronizan automáticamente cuando hay conexión:

1. Usuario registra árbol → Se guarda localmente
2. Se agrega a `sync_queue`
3. Cuando hay internet → Se sincroniza con el backend
4. Se marca como sincronizado

## 🔧 Configuración

### Android

Permisos en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS

Permisos en `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos acceso a tu ubicación para registrar las coordenadas de los árboles</string>
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de los árboles</string>
```

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

## 📱 Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (para Google Play)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Seguridad

- JWT tokens almacenados en `flutter_secure_storage`
- Comunicación HTTPS con el backend
- Validación de certificados SSL
- Encriptación de base de datos local (opcional)

## 📝 Convenciones de Código

- **Naming**: `snake_case` para archivos, `PascalCase` para clases
- **State Management**: Provider pattern
- **Error Handling**: Try-catch con logging
- **Async**: Usar `async/await` en lugar de `.then()`

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'feat: agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y confidencial.

## 👥 Equipo

Desarrollado para el Sistema de Inventario Forestal.
