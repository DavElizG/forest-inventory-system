# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar archivos de proyecto y restaurar dependencias
COPY ["src/ForestInventory.API/ForestInventory.API.csproj", "src/ForestInventory.API/"]
COPY ["src/ForestInventory.Application/ForestInventory.Application.csproj", "src/ForestInventory.Application/"]
COPY ["src/ForestInventory.Domain/ForestInventory.Domain.csproj", "src/ForestInventory.Domain/"]
COPY ["src/ForestInventory.Infrastructure/ForestInventory.Infrastructure.csproj", "src/ForestInventory.Infrastructure/"]

RUN dotnet restore "src/ForestInventory.API/ForestInventory.API.csproj"

# Copiar el resto del código y compilar
COPY . .
WORKDIR "/src/src/ForestInventory.API"
RUN dotnet build "ForestInventory.API.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "ForestInventory.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Instalar herramientas necesarias para Railway
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar aplicación publicada
COPY --from=publish /app/publish .

# Crear directorio para base de datos SQLite (si se usa)
RUN mkdir -p /app/data

# Configurar variables de entorno
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Exponer puerto (Railway asigna dinámicamente)
EXPOSE 8080

ENTRYPOINT ["dotnet", "ForestInventory.API.dll"]
