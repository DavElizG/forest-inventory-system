# Guía de Uso de Swagger con Autenticación JWT 🔐

## 📌 Cambios Implementados

### ✅ 1. Swagger Muestra Candados en Endpoints Protegidos

Ahora todos los endpoints protegidos con `[Authorize]` aparecen con un **candado 🔒** en Swagger UI.

### ✅ 2. Login NO Devuelve el Token

El endpoint de login ahora:
- ✅ Guarda el token automáticamente en una cookie HTTP-Only
- ✅ Solo devuelve información del usuario
- ✅ NO expone el token en la respuesta

**Antes:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {...},
  "expiresAt": "2025-03-22T..."
}
```

**Ahora:**
```json
{
  "usuario": {...},
  "expiresAt": "2025-03-22T...",
  "message": "Login exitoso. Token guardado en cookie segura."
}
```

---

## 🚀 Cómo Usar Swagger con Autenticación

### Opción 1: Autenticación Automática con Cookies (Recomendada)

#### Paso 1: Hacer Login
1. Ve a `/api/auth/login` en Swagger
2. Presiona "Try it out"
3. Ingresa credenciales:
```json
{
  "email": "admin@test.com",
  "password": "Test123!"
}
```
4. Ejecuta el request

**Resultado**: El token se guarda automáticamente en una cookie HTTP-Only

#### Paso 2: Usar Endpoints Protegidos
Ahora puedes usar cualquier endpoint protegido directamente:
- Ve a `/api/arboles` (tiene candado 🔒)
- Presiona "Try it out"
- Ejecuta

**La cookie se envía automáticamente**, no necesitas hacer nada más.

---

### Opción 2: Autenticación Manual con Bearer Token

Si prefieres usar el token manualmente (para testing):

#### Paso 1: Obtener el Token
El token está en la cookie HTTP-Only. Para obtenerlo manualmente:

**Usando Browser DevTools:**
1. Abre DevTools (F12)
2. Ve a Application → Cookies
3. Busca `jwt_token`
4. Copia el valor

**O usando curl:**
```bash
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -v \
  -d '{"email":"admin@test.com","password":"Test123!"}'

# El token estará en cookies.txt
```

#### Paso 2: Autenticarse en Swagger
1. En Swagger UI, presiona el botón **"Authorize"** (arriba a la derecha)
2. En el modal que aparece:
   - Campo "Value": `Bearer <tu-token-aqui>`
   - Ejemplo: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
3. Presiona "Authorize"
4. Cierra el modal

#### Paso 3: Usar Endpoints Protegidos
Ahora todos los endpoints protegidos incluirán el token en el header `Authorization`.

---

## 🔍 Identificar Endpoints Protegidos

En Swagger UI, los endpoints protegidos ahora muestran:

- **Candado cerrado 🔒** - Requiere autenticación
- **Sección "Security"** en la descripción
- **Badge "Authorize"** al expandir el endpoint

### Endpoints Públicos (sin candado)
```
POST /api/auth/login
POST /api/auth/register
```

### Endpoints Protegidos (con candado 🔒)
```
GET  /api/auth/verify
POST /api/auth/logout
GET  /api/arboles
GET  /api/parcelas
GET  /api/especies
GET  /api/export/*
```

### Endpoints Solo Administrador (con candado 🔒 y nota)
```
GET  /api/usuarios
POST /api/usuarios
PUT  /api/usuarios/{id}
DELETE /api/usuarios/{id}
```

---

## 🧪 Flujo de Prueba Completo

### 1. Sin Autenticación (Debe Fallar)
```bash
# Intentar obtener árboles sin autenticación
curl -X GET http://localhost:5001/api/arboles

# Respuesta esperada: 401 Unauthorized
```

### 2. Login Exitoso
```bash
# Login y guardar cookie
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{"email":"admin@test.com","password":"Test123!"}'

# Respuesta esperada:
{
  "usuario": {
    "id": "...",
    "email": "admin@test.com",
    "nombreCompleto": "Administrador Test",
    "rol": "Administrador"
  },
  "expiresAt": "2025-03-22T...",
  "message": "Login exitoso. Token guardado en cookie segura."
}
```

### 3. Usar Endpoint Protegido
```bash
# Obtener árboles con cookie
curl -X GET http://localhost:5001/api/arboles \
  -b cookies.txt

# Respuesta esperada: 200 OK con lista de árboles
```

### 4. Verificar Token
```bash
# Verificar que la sesión sigue activa
curl -X GET http://localhost:5001/api/auth/verify \
  -b cookies.txt

# Respuesta esperada: información del usuario
```

### 5. Logout
```bash
# Cerrar sesión
curl -X POST http://localhost:5001/api/auth/logout \
  -b cookies.txt

# Respuesta esperada: "Sesión cerrada exitosamente"
```

---

## 📊 Configuración Técnica

### Swagger Configuration (Program.cs)

```csharp
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Forest Inventory API",
        Version = "v1",
        Description = "API para gestión de inventario forestal con autenticación JWT"
    });

    // Esquema de seguridad JWT
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingrese 'Bearer' seguido del token JWT"
    });

    // Requisito de seguridad global
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
```

### JWT Authentication (ApplicationBuilderExtensions.cs)

```csharp
options.Events = new JwtBearerEvents
{
    OnMessageReceived = context =>
    {
        // Leer token desde cookie HTTP-Only
        var token = context.Request.Cookies["jwt_token"];
        if (!string.IsNullOrEmpty(token))
        {
            context.Token = token;
        }
        return Task.CompletedTask;
    }
};
```

---

## 🎯 Ventajas de Este Enfoque

### ✅ Seguridad Mejorada
- Token en cookie HTTP-Only (no accesible desde JavaScript)
- Previene ataques XSS
- No expone el token en respuestas JSON

### ✅ Mejor UX
- No necesitas copiar/pegar tokens manualmente
- Autenticación automática en Swagger
- Flujo natural como en un navegador

### ✅ Documentación Clara
- Candados visibles en Swagger
- Descripciones detalladas de cada endpoint
- Información de seguridad clara

---

## 🔧 Solución de Problemas

### Problema: "401 Unauthorized" en Swagger
**Solución:**
1. Verifica que hiciste login exitoso
2. Revisa que la cookie `jwt_token` existe en DevTools
3. Intenta recargar Swagger UI
4. Si persiste, haz logout y login nuevamente

### Problema: Token Expirado
**Solución:**
- Los tokens expiran en 90 días
- Haz login nuevamente para obtener un nuevo token
- La cookie se actualizará automáticamente

### Problema: "403 Forbidden" en `/api/usuarios`
**Solución:**
- Este endpoint requiere rol "Administrador"
- Verifica tu rol con `/api/auth/verify`
- Si no eres administrador, no tendrás acceso

### Problema: No veo los candados en Swagger
**Solución:**
1. Asegúrate de haber reiniciado el backend
2. Limpia cache del navegador (Ctrl+Shift+R)
3. Verifica que el puerto sea el correcto (5001 o 7001)

---

## 📝 Endpoints Documentados

### Auth Controller

| Método | Endpoint | Autenticación | Descripción |
|--------|----------|---------------|-------------|
| POST | `/api/auth/login` | ❌ Pública | Iniciar sesión |
| POST | `/api/auth/register` | ❌ Pública | Registrar usuario |
| POST | `/api/auth/logout` | ✅ Requerida | Cerrar sesión |
| GET | `/api/auth/verify` | ✅ Requerida | Verificar token |

### Resources Controllers

| Método | Endpoint | Autenticación | Roles |
|--------|----------|---------------|-------|
| GET | `/api/arboles` | ✅ Requerida | Todos |
| GET | `/api/parcelas` | ✅ Requerida | Todos |
| GET | `/api/especies` | ✅ Requerida | Todos |
| GET | `/api/usuarios` | ✅ Requerida | **Solo Admin** |
| GET | `/api/export/*` | ✅ Requerida | Todos |
| GET | `/api/synclogs` | ✅ Requerida | Todos |

---

## 🎉 Resumen

**Ahora tu API tiene:**

✅ Swagger UI con candados visibles  
✅ Login que NO expone el token  
✅ Autenticación automática con cookies  
✅ Documentación clara de seguridad  
✅ Flujo de prueba sencillo  
✅ Mejor seguridad (XSS prevention)

**¡Disfruta probando tu API segura!** 🚀

---

**Última actualización**: Diciembre 22, 2025
