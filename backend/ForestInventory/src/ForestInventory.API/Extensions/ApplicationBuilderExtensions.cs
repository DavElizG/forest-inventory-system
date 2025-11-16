using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using ForestInventory.Infrastructure.Repositories.Implementations;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace ForestInventory.API.Extensions;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection ConfigureInfrastructureServices(
        this IServiceCollection services, 
        IConfiguration configuration)
    {
        // Get connection string from environment variable or configuration
        var connectionString = Environment.GetEnvironmentVariable("DATABASE_URL") 
            ?? configuration.GetConnectionString("DefaultConnection");

        // Database Context with PostgreSQL and PostGIS
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(
                connectionString,
                b => 
                {
                    b.MigrationsAssembly("ForestInventory.Infrastructure");
                    b.UseNetTopologySuite(); // Enable spatial data types
                }));

        // Repository Pattern
        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
        services.AddScoped<IArbolRepository, ArbolRepository>();
        services.AddScoped<IParcelaRepository, ParcelaRepository>();
        services.AddScoped<IEspecieRepository, EspecieRepository>();
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }

    public static IServiceCollection ConfigureAuthenticationServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var jwtSettings = configuration.GetSection("JwtSettings");
        
        // Get JWT settings from environment variables or configuration
        var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") 
            ?? jwtSettings["SecretKey"] 
            ?? throw new InvalidOperationException("JWT SecretKey is not configured");
        
        var issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") 
            ?? jwtSettings["Issuer"] 
            ?? "ForestInventoryAPI";
        
        var audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") 
            ?? jwtSettings["Audience"] 
            ?? "ForestInventoryClients";

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = issuer,
                ValidAudience = audience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                ClockSkew = TimeSpan.Zero
            };
        });

        services.AddAuthorization();

        return services;
    }
}
