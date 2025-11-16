namespace ForestInventory.API.Middlewares;

public class TokenValidationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<TokenValidationMiddleware> _logger;

    public TokenValidationMiddleware(RequestDelegate next, ILogger<TokenValidationMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
        var token = authHeader?.Split(" ", StringSplitOptions.RemoveEmptyEntries).LastOrDefault();

        if (!string.IsNullOrEmpty(token))
        {
            _logger.LogInformation("Token detected in request");
            // Additional custom token validation logic can be added here
        }

        await _next(context);
    }
}
