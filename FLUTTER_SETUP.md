# 🚀 Instalación de Flutter en Windows

## Prerequisitos

Antes de instalar Flutter, asegúrate de tener:
- ✅ **Git para Windows** instalado
- ✅ **Visual Studio Code** instalado
- ✅ **Extensión Flutter** instalada en VS Code

## Pasos de Instalación

### 1. Descargar Flutter SDK

1. Ve a: **https://flutter.dev/docs/get-started/install/windows**
2. Descarga el archivo `flutter_windows_3.x.x-stable.zip` (o la versión más reciente)
3. **NO lo descomprimas en `C:\Program Files`** (requiere permisos)
4. Descomprímelo en una ubicación sin restricciones, por ejemplo:
   - `C:\src\flutter` (recomendado)
   - `C:\flutter`
   - `D:\development\flutter`

**Ejemplo con PowerShell:**
```powershell
# Crear carpeta
mkdir C:\src
cd C:\src

# Descargar (reemplaza con versión actual)
# O descarga manualmente desde https://flutter.dev/docs/release/archive

# Descomprimir (si lo descargaste)
Expand-Archive flutter_windows_3.x.x-stable.zip -DestinationPath C:\src
```

### 2. Agregar Flutter a PATH

#### Opción A: Agregar manualmente (Recomendado)

1. **Abre Configuración > Sistema > Configuración avanzada del sistema > Variables de entorno**
2. **Variables de entorno > Variable de sistema > Path > Editar**
3. **Nuevo** y agrega: `C:\src\flutter\bin` (ajusta la ruta según tu instalación)
4. **OK, OK, OK** - Cierra todo

#### Opción B: Con PowerShell (como Admin)

```powershell
# Reemplaza C:\src\flutter con tu ruta real
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\src\flutter\bin", "User")
```

### 3. Verificar Instalación

**Cierra y reabre PowerShell**, luego:

```powershell
flutter --version
```

Deberías ver:
```
Flutter 3.x.x • channel stable
Dart 3.x.x
```

### 4. Ejecutar Flutter Doctor

Este comando verifica que todo está configurado:

```powershell
flutter doctor
```

Verás algo como:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Windows Version
[✓] Android toolchain
[ ] Chrome - develop for the web
[✗] Visual Studio - develop for Windows desktop apps
```

No hay problema si algunas cosas están marcadas con ✗. Los más importantes son:
- ✅ Flutter
- ✅ Windows Version

### 5. Configurar Emulador (Opcional)

Si quieres probar en un emulador Android:

```powershell
flutter emulators
flutter emulators --launch Pixel_5_API_31
```

## ✅ Probando Flutter

Una vez instalado, regresa a tu proyecto:

```powershell
cd C:\Users\JDGua\OneDrive\Escritorio\forest-inventory-system\mobile\silvicola_app

# Obtener dependencias
flutter pub get

# Ejecutar en web (más fácil)
flutter run -d web

# O ejecutar en Android (si tienes emulador)
flutter run
```

## Solución de Problemas

### "flutter: El término no se reconoce"
- Verifica que agregaste `C:\src\flutter\bin` al PATH
- Cierra y reabre PowerShell
- Reinicia VS Code

### "Error: Unable to locate Android SDK"
- Es normal si no tienes Android SDK
- Puedes desarrollar en web con `flutter run -d web`

### "Dart SDK not found"
- Viene incluido con Flutter, pero si da error:
- Ejecuta: `flutter doctor --android-licenses`

## Links Útiles

- 📖 Documentación Oficial: https://flutter.dev/docs
- 🆘 Troubleshooting: https://flutter.dev/docs/get-started/install/windows#troubleshooting
- 📦 Pub.dev (paquetes): https://pub.dev
