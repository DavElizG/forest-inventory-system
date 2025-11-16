# Silvícola Web - Admin Panel

Panel de administración web para el Sistema de Inventario Forestal desarrollado en React + TypeScript + Tailwind CSS.

## 🚀 Características

- ✅ **Dashboard Interactivo**: Visualización de estadísticas y métricas
- 🌲 **Gestión de Árboles**: CRUD completo con mapas
- 📍 **Mapas Interactivos**: Visualización geoespacial con Leaflet
- 👥 **Gestión de Usuarios**: Control de acceso y permisos
- 📊 **Reportes**: Exportación a Excel y KMZ
- 📱 **Responsive**: Diseño adaptable a todos los dispositivos
- 🎨 **Tailwind CSS**: Estilos modernos y personalizables

## 🏗️ Arquitectura

Estructura **Feature-Based**:

```
src/
├── config/         # Configuración de la app
├── types/          # TypeScript types & interfaces
├── services/       # API services
├── hooks/          # Custom React hooks
├── context/        # React Context (Auth, Theme)
├── utils/          # Funciones utilitarias
├── components/     # Componentes reutilizables
└── pages/          # Páginas de la aplicación
```

## 🚀 Comenzar

### Prerrequisitos

- Node.js >= 18.0.0
- pnpm >= 8.0.0

### Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/DavElizG/forest-inventory-system.git
   cd forest-inventory-system/web-admin/silvicola-web
   ```

2. **Instalar dependencias con pnpm**:
   ```bash
   pnpm install
   ```

3. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env.development
   # Editar .env.development con tus valores
   ```

4. **Ejecutar en desarrollo**:
   ```bash
   pnpm dev
   ```

5. **Abrir en el navegador**: http://localhost:5173

## 📦 Scripts Disponibles

```bash
# Desarrollo
pnpm dev

# Build para producción
pnpm build

# Preview del build
pnpm preview

# Linting
pnpm lint
```

## 📦 Dependencias Principales

| Paquete | Propósito |
|---------|-----------|
| `react` | Biblioteca UI |
| `react-router-dom` | Enrutamiento |
| `axios` | Cliente HTTP |
| `zustand` | State management |
| `react-hook-form` | Formularios |
| `zod` | Validación de esquemas |
| `recharts` | Gráficos y charts |
| `leaflet` / `react-leaflet` | Mapas interactivos |
| `lucide-react` | Iconos |
| `tailwindcss` | Estilos CSS |

## 🎨 Estructura de Componentes

### Layouts
- `MainLayout`: Layout principal con sidebar y header
- `Header`: Barra superior con navegación
- `Sidebar`: Menú lateral de navegación
- `Footer`: Pie de página

### Common Components
- `Button`: Botón reutilizable con variantes
- `Input`: Campo de entrada con validación
- `Table`: Tabla con paginación y ordenamiento
- `Modal`: Modal/Dialog reutilizable
- `Loading`: Indicador de carga

### Charts
- `BarChart`: Gráfico de barras
- `PieChart`: Gráfico circular
- `LineChart`: Gráfico de líneas

## 📄 Páginas

- **Login** (`/login`): Autenticación de usuarios
- **Dashboard** (`/`): Panel principal con estadísticas
- **Árboles** (`/arboles`): Gestión de árboles
  - Lista, detalle, formulario
- **Parcelas** (`/parcelas`): Gestión de parcelas
- **Especies** (`/especies`): Catálogo de especies
- **Usuarios** (`/usuarios`): Administración de usuarios
- **Reportes** (`/reportes`): Generación y exportación
- **Mapas** (`/mapas`): Visualización geoespacial
- **Configuración** (`/settings`): Ajustes del sistema

## 🔐 Autenticación

La app usa JWT tokens almacenados en localStorage:
- Login → Obtiene token del backend
- Token se incluye en headers de todas las peticiones
- Auto-logout al expirar el token

## 🗺️ Mapas

Integración con Leaflet:
- Visualización de árboles y parcelas
- Clusters para grandes cantidades de datos
- Capas personalizables
- Exportación a KMZ

## 📊 Reportes

Funcionalidad de exportación:
- **Excel**: Exporta datos tabulares con formato
- **KMZ**: Exporta datos geoespaciales para Google Earth
- **PDF**: Generación de reportes en PDF (futuro)

## 🎨 Theming

Tailwind CSS configurado con colores personalizados:
- Primary: Verde forestal (#2e7d32)
- Secondary: Marrón tierra (#8d6e63)
- Totalmente personalizable en `tailwind.config.js`

## 🧪 Testing

```bash
# Unit tests (futuro)
pnpm test

# E2E tests (futuro)
pnpm test:e2e
```

## 📱 Responsive Design

La app es completamente responsive:
- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

## 🚀 Build & Deploy

### Build para producción
```bash
pnpm build
```

Genera archivos optimizados en `/dist`

### Deploy
```bash
# Vercel
vercel

# Netlify
netlify deploy --prod

# Azure Static Web Apps
# Configurado en GitHub Actions
```

## 🔧 Configuración

### Variables de Entorno

```env
VITE_API_BASE_URL=http://localhost:5000/api
VITE_API_TIMEOUT=30000
VITE_ENVIRONMENT=development
```

### Path Aliases

TypeScript configurado con alias `@/`:
```typescript
import { Button } from '@/components/common/Button';
```

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
