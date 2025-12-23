using System.Net;
using System.Text.Json;
using FluentValidation;

namespace ForestInventory.API.Middlewares;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
            
            // Handle 401 Unauthorized with clear message
            if (context.Response.StatusCode == 401 && !context.Response.HasStarted)
            {
                context.Response.ContentType = "application/json";
                var errorResponse = new
                {
                    StatusCode = 401,
                    Message = "No autorizado",
                    Details = "Su sesión ha expirado o no tiene permisos para acceder a este recurso. Por favor, inicie sesión nuevamente."
                };
                await context.Response.WriteAsync(JsonSerializer.Serialize(errorResponse));
            }
        }
        catch (ValidationException validationEx)
        {
            _logger.LogWarning(validationEx, "Validation error occurred");
            await HandleValidationExceptionAsync(context, validationEx);
        }
        catch (UnauthorizedAccessException)
        {
            _logger.LogWarning("Unauthorized access attempt");
            await HandleUnauthorizedAsync(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleValidationExceptionAsync(HttpContext context, ValidationException exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.BadRequest;

        var errors = exception.Errors
            .Select(e => new { Field = e.PropertyName, Message = e.ErrorMessage })
            .ToList();

        var response = new
        {
            StatusCode = context.Response.StatusCode,
            Message = "Error de validación",
            Errors = errors
        };

        var jsonResponse = JsonSerializer.Serialize(response);
        return context.Response.WriteAsync(jsonResponse);
    }

    private static Task HandleUnauthorizedAsync(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;

        var response = new
        {
            StatusCode = 401,
            Message = "No autorizado",
            Details = "No tiene permisos para acceder a este recurso. Por favor, inicie sesión nuevamente."
        };

        var jsonResponse = JsonSerializer.Serialize(response);
        return context.Response.WriteAsync(jsonResponse);
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

        var response = new
        {
            StatusCode = context.Response.StatusCode,
            Message = "Error interno del servidor",
            Details = "Ha ocurrido un error inesperado. Por favor, intente nuevamente más tarde."
        };

        var jsonResponse = JsonSerializer.Serialize(response);
        return context.Response.WriteAsync(jsonResponse);
    }
}
