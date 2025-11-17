using ForestInventory.Application.Interfaces;
using ForestInventory.Application.Services;
using ForestInventory.Application.Mappings;
using FluentValidation;
using System.Reflection;

namespace ForestInventory.API.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection ConfigureApplicationServices(this IServiceCollection services)
    {
        // AutoMapper
        services.AddAutoMapper(typeof(AutoMapperProfile));

        // FluentValidation
        services.AddValidatorsFromAssembly(Assembly.Load("ForestInventory.Application"));

        // Application Services - only implemented ones
        services.AddScoped<IArbolService, ArbolService>();
        services.AddScoped<IParcelaService, ParcelaService>();
        services.AddScoped<IEspecieService, EspecieService>();
        services.AddScoped<IUsuarioService, UsuarioService>();
        services.AddScoped<ISyncLogService, SyncLogService>();
        
        // TODO: Implement remaining services
        // services.AddScoped<IAuthService, AuthService>();
        // services.AddScoped<IReporteService, ReporteService>();
        // services.AddScoped<IEmailService, EmailService>();
        // services.AddScoped<IExcelExportService, ExcelExportService>();
        // services.AddScoped<IKmzExportService, KmzExportService>();
        // services.AddScoped<ISyncService, SyncService>();

        return services;
    }

    public static IServiceCollection ConfigureCorsPolicy(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("CorsPolicy", builder =>
            {
                var corsOrigins = Environment.GetEnvironmentVariable("CORS_ORIGINS")?.Split(',')
                    ?? configuration.GetSection("CorsOrigins").Get<string[]>()
                    ?? new[] { "http://localhost:5173", "http://localhost:3000" };

                builder.WithOrigins(corsOrigins)
                       .AllowAnyMethod()
                       .AllowAnyHeader()
                       .AllowCredentials();
            });
        });

        return services;
    }
}
