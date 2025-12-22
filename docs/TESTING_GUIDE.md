# Guía de Pruebas Rápidas 🧪

## Backend (.NET API)

### 1. Compilar y Ejecutar

```bash
cd backend/ForestInventory
dotnet restore
dotnet build
dotnet run --project src/ForestInventory.API
```

**API corriendo en**: `https://localhost:7001` o `http://localhost:5001`

### 2. Probar Endpoints

#### 2.1 Registro (Público)
```bash
curl -X POST https://localhost:7001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "Test123!",
    "nombreCompleto": "Administrador Test",
    "rol": "Administrador"
  }'
```

#### 2.2 Login (Público)
```bash
curl -X POST https://localhost:7001/api/auth/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{
    "email": "admin@test.com",
    "password": "Test123!"
  }'
```

**Resultado esperado**: Cookie `jwt_token` guardada en `cookies.txt`

#### 2.3 Verificar Token (Protegido)
```bash
curl -X GET https://localhost:7001/api/auth/verify \
  -H "Content-Type: application/json" \
  -b cookies.txt
```

**Resultado esperado**: Información del usuario autenticado

#### 2.4 Obtener Árboles (Protegido)
```bash
curl -X GET https://localhost:7001/api/arboles \
  -H "Content-Type: application/json" \
  -b cookies.txt
```

**Resultado esperado**: 
- ✅ Con cookie: `200 OK` con lista de árboles
- ❌ Sin cookie: `401 Unauthorized`

#### 2.5 Obtener Usuarios (Solo Administrador)
```bash
curl -X GET https://localhost:7001/api/usuarios \
  -H "Content-Type: application/json" \
  -b cookies.txt
```

**Resultado esperado**:
- ✅ Como Administrador: `200 OK` con lista de usuarios
- ❌ Como otro rol: `403 Forbidden`
- ❌ Sin autenticación: `401 Unauthorized`

#### 2.6 Logout (Protegido)
```bash
curl -X POST https://localhost:7001/api/auth/logout \
  -H "Content-Type: application/json" \
  -b cookies.txt
```

**Resultado esperado**: Cookie eliminada

---

## App Móvil (Flutter)

### 1. Ejecutar en Modo Debug

```bash
cd mobile/silvicola_app
flutter pub get
flutter run
```

### 2. Escenarios de Prueba

#### 2.1 Primera Apertura
**Flujo esperado**:
1. Splash Screen (2 segundos)
2. → Login Screen (sin sesión guardada)

#### 2.2 Login Exitoso
**Pasos**:
1. Ingresar email: `admin@test.com`
2. Ingresar password: `Test123!`
3. ✅ Marcar "Mantener sesión activa"
4. Presionar "Iniciar Sesión"

**Resultado esperado**:
- Loading indicator durante proceso
- Navegación a Home Screen
- Nombre de usuario visible en AppBar

#### 2.3 Login Fallido
**Pasos**:
1. Ingresar credenciales incorrectas
2. Presionar "Iniciar Sesión"

**Resultado esperado**:
- Mensaje de error: "Credenciales inválidas"
- Permanecer en Login Screen

#### 2.4 Auto-Login
**Pasos**:
1. Cerrar app (después de login exitoso con "mantener sesión")
2. Reabrir app

**Resultado esperado**:
1. Splash Screen
2. → Home Screen (auto-login automático)

#### 2.5 Navegación a Rutas Protegidas
**Pasos**:
1. Desde Home, ir a "Árboles"
2. Desde Home, ir a "Parcelas"
3. Desde Home, ir a "Configuración"

**Resultado esperado**:
- ✅ Acceso permitido (usuario autenticado)
- Contenido de cada pantalla visible

#### 2.6 Intento de Acceso Sin Autenticación
**Pasos**:
1. Hacer logout
2. Intentar acceder directamente a `/arboles` (mediante deep link)

**Resultado esperado**:
- Redirección automática a Login Screen
- Ruta guardada como pendiente
- Después del login → navegación a `/arboles`

#### 2.7 Logout
**Pasos**:
1. Ir a Configuración
2. Presionar "Cerrar Sesión"
3. Confirmar en diálogo

**Resultado esperado**:
- Diálogo de confirmación
- Navegación a Login Screen
- Credenciales eliminadas

#### 2.8 Información de Usuario
**Pasos**:
1. Ir a Configuración

**Resultado esperado**:
- Card con información del usuario:
  - Nombre completo
  - Email
  - Rol

---

## Pruebas de Seguridad

### Backend

#### Test 1: Acceso sin Token
```bash
curl -X GET https://localhost:7001/api/arboles
```
**Esperado**: `401 Unauthorized`

#### Test 2: Token Inválido
```bash
curl -X GET https://localhost:7001/api/arboles \
  -H "Cookie: jwt_token=invalid_token_here"
```
**Esperado**: `401 Unauthorized`

#### Test 3: Rol Insuficiente
```bash
# Login como TecnicoForestal
curl -X POST https://localhost:7001/api/auth/login \
  -H "Content-Type: application/json" \
  -c cookies_tecnico.txt \
  -d '{
    "email": "tecnico@test.com",
    "password": "Test123!"
  }'

# Intentar acceder a usuarios (solo Administrador)
curl -X GET https://localhost:7001/api/usuarios \
  -b cookies_tecnico.txt
```
**Esperado**: `403 Forbidden`

### App Móvil

#### Test 1: Navegación sin Autenticación
1. Abrir app sin sesión
2. Cambiar manualmente URL a ruta protegida

**Esperado**: Redirección a Login

#### Test 2: Sesión Expirada
1. Login exitoso
2. Esperar expiración de token (o invalidar en backend)
3. Intentar usar la app

**Esperado**: Redirección a Login

#### Test 3: Credenciales Persistentes
1. Login con "mantener sesión"
2. Cerrar app
3. Reabrir app

**Esperado**: Auto-login exitoso

---

## Checklist de Funcionalidades ✅

### Backend
- [x] Todos los controladores protegidos
- [x] Roles implementados
- [x] JWT en cookies HTTP-Only
- [x] Validación de tokens
- [x] CORS configurado
- [x] Logout limpia cookies
- [x] Endpoints públicos funcionan

### Mobile
- [x] Guards en todas las rutas protegidas
- [x] Auto-login funciona
- [x] Login/Logout funcionan
- [x] Rutas pendientes se guardan
- [x] Información de usuario visible
- [x] Navegación protegida
- [x] Credenciales se almacenan seguramente

---

## Errores Comunes y Soluciones

### Backend

#### Error: `JWT SecretKey is not configured`
**Solución**: Agregar `JWT_SECRET_KEY` en `.env`:
```env
JWT_SECRET_KEY=tu-clave-secreta-muy-larga-y-segura-aqui
```

#### Error: `Cannot connect to database`
**Solución**: Verificar PostgreSQL corriendo:
```bash
docker-compose up -d
```

### Mobile

#### Error: `Connection refused`
**Solución**: 
- Android Emulator: usar `10.0.2.2` en lugar de `localhost`
- iOS Simulator: usar `localhost`

```dart
// En .env
API_BASE_URL=http://10.0.2.2:5001  // Android
API_BASE_URL=http://localhost:5001 // iOS
```

#### Error: `SecureStorage not available`
**Solución**: Solo ocurre en web, implementar fallback:
```dart
// Ya implementado en SecureStorageService
```

---

## Métricas de Rendimiento Esperadas

| Operación | Tiempo Esperado |
|-----------|-----------------|
| Login | < 500ms |
| Verificar Token | < 200ms |
| Cargar Árboles | < 1s |
| Auto-Login | < 800ms |
| Logout | < 300ms |

---

## Reportar Issues

Si encuentras algún problema:

1. Verificar logs del backend
2. Verificar logs de Flutter (console)
3. Revisar estado de autenticación en DevTools
4. Crear issue en GitHub con:
   - Pasos para reproducir
   - Logs relevantes
   - Comportamiento esperado vs actual

---

**Última actualización**: Diciembre 22, 2025  
**Estado**: Sistema listo para pruebas QA 🚀
