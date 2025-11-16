# Changelog

Todos los cambios notables del proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

#### Changed
- Migración de SQL Server a PostgreSQL con PostGIS
- JWT expiración extendida a 90 días para uso en campo

### Mobile
#### Added
- Estructura del proyecto Flutter preparada

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
