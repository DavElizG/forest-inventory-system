# Implementación de Seguridad - Sistema de Inventario Forestal

## Backend (.NET)

### Protección de Rutas con JWT

Todos los controladores del API ahora están protegidos con autenticación JWT:

#### Controladores Protegidos:

1. **ArbolesController** - `[Authorize]`
   - Requiere autenticación para todas las operaciones
   - Acceso para todos los roles autenticados

2. **ParcelasController** - `[Authorize]`
   - Requiere autenticación para todas las operaciones
   - Acceso para todos los roles autenticados

3. **EspeciesController** - `[Authorize]`
   - Requiere autenticación para todas las operaciones
   - Acceso para todos los roles autenticados

4. **UsuariosController** - `[Authorize(Roles = "Administrador")]`
   - Requiere autenticación Y rol de Administrador
   - Solo administradores pueden gestionar usuarios

5. **ExportController** - `[Authorize]`
   - Requiere autenticación para exportaciones
   - Acceso para todos los roles autenticados

6. **SyncLogsController** - `[Authorize]`
   - Requiere autenticación para logs de sincronización
   - Acceso para todos los roles autenticados

7. **AuthController** - Rutas públicas y protegidas
   - `/login` - Pública
   - `/register` - Pública
   - `/logout` - Protegida con `[Authorize]`
   - `/verify` - Protegida con `[Authorize]`

### Configuración de JWT

- **Tokens en Cookies HTTP-Only**: Los tokens JWT se almacenan en cookies seguras para prevenir ataques XSS
- **Validación de Tokens**: Todos los tokens se validan en cada request
- **Expiración**: Los tokens tienen tiempo de expiración configurable
- **Roles**: Sistema de roles implementado (Administrador, Supervisor, TécnicoForestal, Consultor)

### CORS Configurado

- Solo orígenes permitidos pueden acceder al API
- Credenciales habilitadas para cookies
- Configuración en `appsettings.json` y variables de entorno

## App Móvil (Flutter)

### Sistema de Autenticación

#### AuthGuard

Se implementó un sistema completo de guards de navegación:

**Archivo**: `lib/core/guards/auth_guard.dart`

- `AuthGuard.checkAuth()`: Verifica si el usuario está autenticado
- `AuthGuard.navigateToProtectedRoute()`: Navega con protección
- `AuthGuardedRoute`: Widget wrapper para rutas protegidas

#### Rutas Protegidas

Todas las rutas principales están protegidas con `AuthGuardedRoute`:

```dart
- /home - Home principal
- /arboles - Lista de árboles
- /arboles/form - Formulario de árboles
- /arboles/detail - Detalle de árbol
- /parcelas - Lista de parcelas
- /parcelas/form - Formulario de parcelas
- /especies - Lista de especies
- /sync - Sincronización
- /sync/preview - Vista previa de sincronización
- /reportes - Reportes
- /settings - Configuración
```

#### Funcionalidades de Seguridad

1. **Auto-Login**:
   - Al abrir la app, intenta verificar token existente
   - Si falla, intenta auto-login con credenciales guardadas
   - Solo si el usuario seleccionó "Mantener sesión activa"

2. **Rutas Pendientes**:
   - Si un usuario intenta acceder a una ruta protegida sin autenticación
   - Se guarda la ruta deseada
   - Después del login, se redirige automáticamente a esa ruta

3. **Logout Seguro**:
   - Confirmación antes de cerrar sesión
   - Limpieza completa de datos sensibles
   - Redirección automática al login

4. **Almacenamiento Seguro**:
   - Uso de `SecureStorageService` para credenciales
   - Datos del usuario encriptados
   - Tokens no se almacenan en el dispositivo (solo en cookies HTTP-only del backend)

### Pantallas Actualizadas

#### SplashScreen
- Implementa auto-login automático
- Verifica sesión existente antes de navegar

#### LoginScreen
- Maneja rutas pendientes después del login exitoso
- Opción "Mantener sesión activa"
- Validación de formularios

#### SettingsScreen
- Muestra información del usuario autenticado
- Botón de logout con confirmación
- Cambio de tema

#### HomeScreen
- Muestra nombre de usuario en AppBar
- Acceso solo para usuarios autenticados

## Escaneo de Seguridad con Snyk

### Resultados del Análisis

✅ **Backend (.NET)**: Sin vulnerabilidades detectadas
✅ **App Móvil (Flutter)**: Sin vulnerabilidades detectadas

### Vulnerabilidades Prevenidas

Se implementaron las siguientes medidas de seguridad preventivas:

1. **Autenticación JWT con Cookies HTTP-Only** - Previene XSS
2. **Validación de Roles** - Previene escalación de privilegios
3. **Guards de Navegación** - Previene acceso no autorizado
4. **Almacenamiento Seguro** - Protege credenciales sensibles
5. **Validación de Formularios** - Previene inyección de datos maliciosos

## Roles del Sistema

```csharp
public enum RolUsuario
{
    Administrador = 1,      // Acceso completo
    Supervisor = 2,          // Gestión de datos
    TecnicoForestal = 3,    // Operaciones de campo
    Consultor = 4           // Solo lectura
}
```

## Próximos Pasos Recomendados

1. **Rate Limiting**: Implementar límites de requests por IP
2. **Logging de Seguridad**: Registrar intentos de acceso no autorizado
3. **2FA (Autenticación de Dos Factores)**: Para usuarios administradores
4. **Auditoría**: Sistema de logs de auditoría para acciones críticas
5. **Refresh Tokens**: Implementar refresh tokens para mejor UX
6. **Password Policy**: Políticas más estrictas de contraseñas
7. **Account Lockout**: Bloqueo de cuenta después de X intentos fallidos

## Variables de Entorno Requeridas

### Backend
```env
JWT_SECRET_KEY=<clave-secreta-segura>
JWT_ISSUER=ForestInventoryAPI
JWT_AUDIENCE=ForestInventoryClients
DATABASE_URL=<connection-string>
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Mobile App
```env
API_BASE_URL=https://api.ejemplo.com
```

## Comandos de Prueba

### Backend
```bash
cd backend/ForestInventory
dotnet build
dotnet test
dotnet run --project src/ForestInventory.API
```

### Mobile
```bash
cd mobile/silvicola_app
flutter pub get
flutter analyze
flutter test
flutter run
```

---

**Fecha de Implementación**: Diciembre 22, 2025
**Estado**: ✅ Completado
**Cobertura de Seguridad**: Alta
