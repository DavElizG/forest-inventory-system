# Forest Inventory System - Monorepo

Sistema completo de inventario forestal que permite capturar datos de árboles y parcelas en campo, sincronizar datos y generar reportes.

## 🎯 Proyectos del Monorepo

### Backend - **ForestInventory** (.NET 8)
- **Ubicación**: `backend/ForestInventory/`
- **Descripción**: API REST con arquitectura limpia para gestión de datos forestales
- **Stack**: .NET 8, PostgreSQL 16, PostGIS, Entity Framework Core
- **Puerto**: 5001 (HTTP), 7001 (HTTPS)

### Mobile - **Silvicola** (Flutter)
- **Ubicación**: `mobile/silvicola_app/`
- **Descripción**: App móvil multiplataforma para captura de datos en campo
- **Stack**: Flutter 3.24+, SQLite, Geolocator
- **Características**: Modo offline, sincronización, GPS alta precisión

### Web Admin - **Silvicola Web** (React + TypeScript)
- **Ubicación**: `web-admin/silvicola-web/`
- **Descripción**: Panel de administración web
- **Stack**: React 18, TypeScript 5, Vite, pnpm
- **Puerto**: 5173 (desarrollo)

## 🚀 Inicio Rápido

### Requisitos Previos

- **Backend**: .NET 8 SDK, PostgreSQL 16 con PostGIS
- **Mobile**: Flutter 3.24+, Android Studio / Xcode
- **Web**: Node.js 20+, pnpm 8+

### Configuración Inicial

#### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-org/forest-inventory-system.git
cd forest-inventory-system
```

#### 2. Backend (.NET)
```bash
cd backend/ForestInventory

# Copiar variables de entorno
cp .env.example .env

# Editar .env con tus credenciales
# DATABASE_URL, JWT_SECRET_KEY, SMTP_*, etc.

# Restaurar dependencias
dotnet restore

# Crear base de datos (asegúrate de tener PostgreSQL corriendo)
dotnet ef database update --project src/ForestInventory.Infrastructure --startup-project src/ForestInventory.API

# Ejecutar API
dotnet run --project src/ForestInventory.API
```

#### 3. Web Admin (React)
```bash
cd web-admin/silvicola-web

# Instalar dependencias
pnpm install

# Crear archivo de variables de entorno
cp .env.example .env.local

# Editar .env.local
# VITE_API_BASE_URL=http://localhost:5001

# Ejecutar en desarrollo
pnpm dev
```

#### 4. Mobile (Flutter)
```bash
cd mobile/silvicola_app

# Instalar dependencias
flutter pub get

# Ejecutar en emulador/dispositivo
flutter run
```

## 📂 Estructura del Monorepo

```
forest-inventory-system/
├── .github/
│   └── workflows/              # CI/CD workflows
│       ├── backend-ci.yml      # Tests y build backend
│       ├── mobile-ci.yml       # Tests y build mobile
│       └── web-admin-ci.yml    # Tests y build web
│
├── backend/
│   └── ForestInventory/        # API .NET 8
│       ├── src/
│       │   ├── ForestInventory.API/
│       │   ├── ForestInventory.Application/
│       │   ├── ForestInventory.Domain/
│       │   └── ForestInventory.Infrastructure/
│       ├── tests/
│       └── .env.example
│
├── mobile/
│   └── silvicola_app/          # App Flutter
│       ├── lib/
│       ├── android/
│       ├── ios/
│       └── test/
│
├── web-admin/
│   └── silvicola-web/          # Panel React
│       ├── src/
│       ├── public/
│       └── .env.example
│
├── docs/                       # Documentación técnica
│   ├── REQUIREMENTS.md
│   ├── API_DOCUMENTATION.md
│   ├── DATABASE_SCHEMA.md
│   ├── DEPLOYMENT.md
│   └── USER_MANUAL.md
│
├── shared/
│   └── types/                  # Tipos compartidos
│
├── .gitignore
├── docker-compose.yml
├── CHANGELOG.md
└── README.md
```

## 🔐 Variables de Entorno

### Backend
Copia `.env.example` a `.env` en `backend/ForestInventory/`:

```env
DATABASE_URL=Host=localhost;Port=5432;Database=forestdb;Username=forestuser;Password=your_password
JWT_SECRET_KEY=your-secret-key-minimum-32-characters
JWT_ISSUER=ForestInventoryAPI
JWT_AUDIENCE=ForestInventoryClients
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@example.com
SMTP_PASSWORD=your-app-password
```

### Web Admin
Crea `.env.local` en `web-admin/silvicola-web/`:

```env
VITE_API_BASE_URL=http://localhost:5001
VITE_API_VERSION=v1
```

## 🐳 Docker

```bash
# Levantar todos los servicios
docker-compose up -d

# Solo base de datos PostgreSQL
docker-compose up postgres -d

# Ver logs
docker-compose logs -f
```

## 🧪 Testing

### Backend
```bash
cd backend/ForestInventory
dotnet test --verbosity normal
```

### Mobile
```bash
cd mobile/silvicola_app
flutter test
```

### Web Admin
```bash
cd web-admin/silvicola-web
pnpm test
```

## 📝 Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat: agregar exportación KMZ
fix: corregir sincronización offline  
docs: actualizar README
refactor: reestructurar servicio de árboles
test: agregar tests para ArbolService
chore: actualizar dependencias
```

## 🌿 Flujo de Trabajo Git

```bash
# Crear rama de feature
git checkout -b feature/mi-feature

# Commits convencionales
git commit -m "feat: implementar cálculo de volumen"

# Push y crear PR
git push origin feature/mi-feature
```

**Branches principales:**
- `main`: Producción estable
- `develop`: Desarrollo activo
- `feature/*`: Nuevas funcionalidades
- `fix/*`: Correcciones de bugs

## 📖 Documentación

- [Requerimientos Técnicos](docs/REQUIREMENTS.md)
- [Documentación API](docs/API_DOCUMENTATION.md)
- [Esquema Base de Datos](docs/DATABASE_SCHEMA.md)
- [Guía de Deployment](docs/DEPLOYMENT.md)
- [Manual de Usuario](docs/USER_MANUAL.md)

## 🚀 Deployment

### Backend (Railway)
```bash
# Deploy automático desde main branch
# Configurar variables de entorno en Railway Dashboard
```

### Web Admin (Vercel/Netlify)
```bash
# Deploy automático desde main branch
# Configurar VITE_API_BASE_URL en settings
```

### Mobile (Google Play)
```bash
cd mobile/silvicola_app
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

## 📊 Stack Tecnológico

| Componente | Tecnología |
|------------|------------|
| **Backend** | .NET 8, PostgreSQL 16, PostGIS |
| **Mobile** | Flutter 3.24+, SQLite |
| **Web** | React 18, TypeScript 5, Vite |
| **Autenticación** | JWT (90 días expiración) |
| **Email** | SMTP (Gmail/SendGrid) |
| **CI/CD** | GitHub Actions |
| **Hosting** | Railway, Vercel, Netlify |

## 👥 Roles del Sistema

- **Técnico Forestal**: Captura datos en campo, exporta reportes
- **Administrador**: Gestión completa, usuarios, estadísticas

## 🆘 Soporte

Para reportar bugs o solicitar features, crea un issue en:
https://github.com/tu-org/forest-inventory-system/issues

## 📄 Licencia

[Por definir]

---

**Silvicola** - *Del latín: silva (bosque) + cola (habitante/cultivador)*
