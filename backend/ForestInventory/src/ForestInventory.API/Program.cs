using ForestInventory.API.Extensions;
using ForestInventory.API.Middlewares;
using ForestInventory.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using DotEnv.Core;
using Microsoft.OpenApi.Models;

// Load environment variables from .env file
new EnvLoader().Load();

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT authentication
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Forest Inventory API",
        Version = "v1",
        Description = "API para gestión de inventario forestal con autenticación JWT",
        Contact = new OpenApiContact
        {
            Name = "Silvícola Team",
            Email = "support@silvicola.com"
        }
    });

    // Definir esquema de seguridad JWT
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingrese 'Bearer' seguido de un espacio y el token JWT.\n\nEjemplo: \"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\"\n\nNota: El token también se puede enviar automáticamente mediante cookies HTTP-Only."
    });

    // Agregar requisito de seguridad global
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

    // Habilitar anotaciones XML para documentación (opcional)
    // var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    // var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    // options.IncludeXmlComments(xmlPath);
});

// Configure custom services through extensions
builder.Services.ConfigureApplicationServices();
builder.Services.ConfigureInfrastructureServices(builder.Configuration);
builder.Services.ConfigureAuthenticationServices(builder.Configuration);
builder.Services.ConfigureCorsPolicy(builder.Configuration);

var app = builder.Build();

// Apply pending migrations automatically (for Railway deployment)
using (var scope = app.Services.CreateScope())
{
    try
    {
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        context.Database.Migrate();
        Console.WriteLine("✅ Database migrations applied successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error applying migrations: {ex.Message}");
        // Don't throw - let the app start anyway for debugging
    }
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Forest Inventory API v1");
        options.DocumentTitle = "Forest Inventory API";
        options.DisplayRequestDuration();
        options.EnableTryItOutByDefault();
        
        // Instrucciones para autenticación
        options.HeadContent = @"
            <style>
                .swagger-ui .info .title { color: #2d5016; }
                .swagger-ui .scheme-container { background: #f0f7ed; }
            </style>
        ";
    });
}

// Redirect root to Swagger in development
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

// Custom middlewares
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<RequestLoggingMiddleware>();

app.UseHttpsRedirection();
app.UseCors("CorsPolicy");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
