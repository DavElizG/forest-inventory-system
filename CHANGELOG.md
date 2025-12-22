# Changelog

Todos los cambios notables del proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security 🔒
#### Added
- Sistema completo de protección de rutas en backend con `[Authorize]`
- Control de acceso basado en roles (UsuariosController solo para Administradores)
- Sistema de guards de navegación en Flutter (`AuthGuard` y `AuthGuardedRoute`)
- Auto-login seguro con verificación de token en app móvil
- Manejo de rutas pendientes después del login
- Pantalla de configuración con logout seguro
- Almacenamiento seguro de credenciales en Flutter
- JWT en cookies HTTP-Only para prevenir XSS
- Análisis de seguridad con Snyk (0 vulnerabilidades detectadas)

### Backend
#### Added
- Arquitectura limpia con 4 capas (API, Application, Domain, Infrastructure)
- Entidades del dominio: Arbol, Parcela, Especie, Usuario, SyncLog
- Configuración de PostgreSQL 16 con PostGIS
- Soporte para variables de entorno
- Patrón Repository y Unit of Work
- Configuración de JWT con expiración de 90 días
- Middlewares de logging y manejo de excepciones
- FluentValidation para validación de datos
- AutoMapper para mapeo de objetos
- Preparación para exportación Excel (EPPlus) y KMZ (SharpKml)
- Protección completa de rutas con atributos `[Authorize]`

#### Changed
- Migración de SQL Server a PostgreSQL con PostGIS
- JWT expiración extendida a 90 días para uso en campo

#### Security
- Todos los controladores principales protegidos con autenticación JWT
- UsuariosController restringido a rol Administrador
- ExportController, SyncLogsController, ArbolesController, ParcelasController, EspeciesController protegidos

### Mobile
#### Added
- Estructura del proyecto Flutter preparada
- Sistema completo de guards de autenticación
- Widget `AuthGuardedRoute` para proteger rutas
- Funcionalidad de auto-login con credenciales guardadas
- Manejo de rutas pendientes en AuthProvider
- Pantalla de configuración mejorada con información de usuario
- Logout seguro con confirmación
- Redirección automática al login cuando expira la sesión

#### Security
- Todas las rutas principales protegidas con `AuthGuardedRoute`
- Almacenamiento seguro con `SecureStorageService`
- Verificación automática de sesión en SplashScreen
- Limpieza segura de datos al cerrar sesión

### Documentation
#### Added
- Documentación completa de implementación de seguridad
- Guía de roles del sistema
- Instrucciones de configuración de variables de entorno
- Recomendaciones de próximos pasos de seguridad

### Web Admin
#### Added
- Estructura del proyecto React + TypeScript preparada

### Infrastructure
#### Added
- CI/CD workflows para Backend, Mobile y Web Admin
- Docker Compose con PostgreSQL + PostGIS
- Configuración de monorepo
- Documentación inicial del proyecto

## [0.1.0] - 2025-11-16

### Added
- Inicio del proyecto
- Estructura base del monorepo
- Configuración inicial de .NET 8 backend
- Documentación de requerimientos técnicos
