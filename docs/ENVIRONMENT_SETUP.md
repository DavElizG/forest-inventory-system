# Forest Inventory System - Environment Configuration

This guide explains how to configure environment variables for the Forest Inventory System.

## Quick Start

1. **Copy the appropriate example file**:
   ```bash
   # For development
   cp .env.development.example .env.development
   
   # For production
   cp .env.production.example .env.production
   ```

2. **Edit the file** with your actual credentials

3. **NEVER commit** `.env`, `.env.development`, or `.env.production` files to git

## Environment Files

- **`.env.example`**: Generic template with placeholder values
- **`.env.development.example`**: Development-specific template with local defaults
- **`.env.production.example`**: Production-specific template with secure defaults
- **`.env.development`**: Your actual development configuration (git-ignored)
- **`.env.production`**: Your actual production configuration (git-ignored)

## Required Variables

### Database Configuration
```
DATABASE_URL=Host=localhost;Port=5432;Database=forestdb;Username=user;Password=pass
```
PostgreSQL connection string with host, port, database name, credentials.

### JWT Authentication
```
JWT_SECRET_KEY=your-secret-key-minimum-32-characters-long
JWT_ISSUER=ForestInventoryAPI
JWT_AUDIENCE=ForestInventoryClients
```
- **JWT_SECRET_KEY**: Must be at least 32 characters. Use 64+ for production.
- **JWT_ISSUER**: API identifier
- **JWT_AUDIENCE**: Client applications identifier

### SMTP Email Configuration
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=noreply@forestinventory.com
```
Required for sending emails (password resets, notifications, etc.)

### CORS Origins
```
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```
Comma-separated list of allowed frontend origins.

## How Variables are Loaded

The application reads variables in this order:

1. **System environment variables** (highest priority)
2. **`.env.{ENVIRONMENT}` file** (e.g., `.env.development`, `.env.production`)
3. **`.env` file** (fallback)
4. **appsettings.json** (lowest priority - only for non-sensitive defaults)

## Setting up Development Environment

1. **Install PostgreSQL with PostGIS**:
   ```bash
   # Using Docker
   docker-compose up -d postgres
   
   # Or install locally
   # Download from https://www.postgresql.org/download/
   ```

2. **Create `.env.development`**:
   ```bash
   cp .env.development.example .env.development
   ```

3. **Update database credentials** in `.env.development`:
   ```
   DATABASE_URL=Host=localhost;Port=5432;Database=forestdb_dev;Username=forestuser;Password=your_password
   ```

4. **Set up SMTP** (optional for development):
   - Use [Mailtrap](https://mailtrap.io/) for testing emails
   - Or leave SMTP settings empty if not testing email features

5. **Run migrations**:
   ```bash
   cd backend/ForestInventory
   dotnet ef migrations add InitialCreate --project src/ForestInventory.Infrastructure --startup-project src/ForestInventory.API
   dotnet ef database update --project src/ForestInventory.Infrastructure --startup-project src/ForestInventory.API
   ```

## Production Deployment

### Option 1: Environment Variables (Recommended)

Set environment variables directly in your hosting platform:

**Azure App Service**:
```bash
az webapp config appsettings set --name your-app --resource-group your-rg --settings \
  DATABASE_URL="Host=..." \
  JWT_SECRET_KEY="..." \
  SMTP_HOST="..." \
  # ... other variables
```

**Docker**:
```bash
docker run -e DATABASE_URL="Host=..." -e JWT_SECRET_KEY="..." your-image
```

**Kubernetes**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: forest-inventory-secrets
type: Opaque
stringData:
  DATABASE_URL: "Host=..."
  JWT_SECRET_KEY: "..."
```

### Option 2: .env File

1. Create `.env.production` on the server (NEVER in git)
2. Set restrictive file permissions:
   ```bash
   chmod 600 .env.production
   ```
3. Ensure the file is loaded by your deployment process

## Security Best Practices

### ✅ DO:
- Use strong, unique passwords and secret keys
- Use at least 64 characters for JWT_SECRET_KEY in production
- Store production secrets in secure vaults (Azure Key Vault, AWS Secrets Manager, etc.)
- Rotate secrets regularly
- Use SSL/TLS for database connections in production
- Limit CORS origins to your actual domains

### ❌ DON'T:
- Commit `.env`, `.env.development`, or `.env.production` to git
- Use development secrets in production
- Share secrets via email, chat, or screenshots
- Use weak or default passwords
- Expose secrets in logs or error messages

## Verifying Configuration

Run this command to check if variables are loaded correctly:

```bash
cd backend/ForestInventory/src/ForestInventory.API
dotnet run
```

Check the startup logs for any configuration warnings or errors.

## Troubleshooting

### Variables not loading
- Ensure file is named exactly `.env.development` or `.env.production`
- Check file is in the project root directory
- Verify file has Unix line endings (LF, not CRLF)
- Ensure no spaces around `=` in variable assignments

### Database connection fails
- Verify PostgreSQL is running
- Check credentials are correct
- Ensure database exists
- Verify PostGIS extension is installed: `CREATE EXTENSION IF NOT EXISTS postgis;`

### JWT errors
- Ensure JWT_SECRET_KEY is at least 32 characters
- Verify no extra whitespace in the secret key
- Check JWT_ISSUER and JWT_AUDIENCE match client configuration

## Getting Help

- Check logs: `docker-compose logs api`
- Verify database: `docker-compose exec postgres psql -U forestuser -d forestdb_dev`
- Test SMTP: Use a tool like [SMTP Tester](https://www.smtper.net/)

For more information, see the main [README.md](../README.md).
