# Forest Inventory System - Backend

Sistema de inventario forestal desarrollado con .NET 8.0 siguiendo principios de Arquitectura Limpia (Clean Architecture).

## 🏗️ Estructura del Proyecto

```
backend/ForestInventory/
├── src/
│   ├── ForestInventory.API/              # Capa de Presentación (Web API)
│   ├── ForestInventory.Application/      # Capa de Aplicación (Lógica de Negocio)
│   ├── ForestInventory.Domain/           # Capa de Dominio (Entidades Core)
│   └── ForestInventory.Infrastructure/   # Capa de Infraestructura (Acceso a Datos)
│
├── tests/
│   ├── ForestInventory.UnitTests/        # Pruebas Unitarias
│   └── ForestInventory.IntegrationTests/ # Pruebas de Integración
│
└── ForestInventory.sln                   # Archivo de Solución
```

## 📦 Dependencias entre Capas

```
API → Application → Domain
API → Infrastructure → Application → Domain
```

- **Domain**: No tiene dependencias externas (núcleo del sistema)
- **Application**: Depende solo de Domain
- **Infrastructure**: Depende de Domain y Application
- **API**: Depende de Application e Infrastructure

## 🚀 Comandos Útiles

### Compilar la solución
```bash
dotnet build
```

### Restaurar paquetes NuGet
```bash
dotnet restore
```

### Ejecutar el proyecto API
```bash
dotnet run --project src/ForestInventory.API
```

### Ejecutar pruebas
```bash
dotnet test
```

### Crear una nueva migración (Entity Framework)
```bash
dotnet ef migrations add NombreMigracion --project src/ForestInventory.Infrastructure --startup-project src/ForestInventory.API
```

### Aplicar migraciones a la base de datos
```bash
dotnet ef database update --project src/ForestInventory.Infrastructure --startup-project src/ForestInventory.API
```

## 🔧 Tecnologías Utilizadas

- **.NET 8.0**: Framework principal
- **Entity Framework Core 8.0**: ORM para acceso a datos
- **SQL Server**: Base de datos
- **AutoMapper**: Mapeo de objetos
- **FluentValidation**: Validación de datos
- **JWT Bearer**: Autenticación
- **Swagger/OpenAPI**: Documentación de API
- **xUnit**: Framework de pruebas
- **Moq**: Librería de mocking para pruebas

## 📝 Configuración

### Cadena de Conexión
Actualiza la cadena de conexión en `src/ForestInventory.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ForestInventoryDB;Trusted_Connection=true;MultipleActiveResultSets=true"
  }
}
```

### Configuración JWT
Actualiza las configuraciones de JWT en `appsettings.json`:

```json
{
  "JwtSettings": {
    "SecretKey": "tu-clave-secreta-aqui",
    "Issuer": "ForestInventoryAPI",
    "Audience": "ForestInventoryClient",
    "ExpirationInMinutes": 60
  }
}
```

## 🎯 Próximos Pasos

1. Implementar DTOs completos en `ForestInventory.Application/DTOs`
2. Completar implementación de servicios
3. Crear validadores con FluentValidation
4. Implementar controladores de API
5. Agregar pruebas unitarias e integración
6. Configurar migraciones de Entity Framework
7. Implementar autenticación y autorización completa

## 📚 Documentación API

Una vez ejecutado el proyecto, la documentación Swagger estará disponible en:
```
https://localhost:7XXX/swagger
```

## 🔒 Seguridad

- Las contraseñas se almacenan hasheadas
- Autenticación basada en JWT
- Autorización por roles
- Validación de entrada en todas las operaciones

## 👥 Roles de Usuario

- **Administrador**: Acceso completo al sistema
- **Supervisor**: Gestión de parcelas y usuarios
- **TécnicoForestal**: Creación y edición de registros de árboles
- **Consultor**: Solo lectura de datos

## 📄 Licencia

[Por definir]
