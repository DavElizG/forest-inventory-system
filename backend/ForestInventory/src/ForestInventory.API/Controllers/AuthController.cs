using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ForestInventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;
    private readonly PasswordMigrationService _passwordMigrationService;

    public AuthController(
        IAuthService authService, 
        ILogger<AuthController> logger,
        PasswordMigrationService passwordMigrationService)
    {
        _authService = authService;
        _logger = logger;
        _passwordMigrationService = passwordMigrationService;
    }

    /// <summary>
    /// Iniciar sesión
    /// </summary>
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponseDto>> Login(LoginDto loginDto)
    {
        try
        {
            var response = await _authService.LoginAsync(loginDto);
            
            // Configurar cookie con el token JWT
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true, // HTTPS en producción
                SameSite = SameSiteMode.Strict,
                Expires = response.ExpiresAt
            };
            
            Response.Cookies.Append("jwt_token", response.Token, cookieOptions);
            
            // No devolver el token en el response por seguridad
            return Ok(new { usuario = response.Usuario, expiresAt = response.ExpiresAt });
        }
        catch (UnauthorizedAccessException ex)
        {
            _logger.LogWarning(ex, "Intento de login fallido para: {Email}", LogSanitizer.SanitizeEmail(loginDto.Email));
            return Unauthorized(new { error = "Credenciales inválidas" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login para: {Email}", LogSanitizer.SanitizeEmail(loginDto.Email));
            return StatusCode(500, new { error = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Registrar un nuevo usuario
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<LoginResponseDto>> Register(RegisterDto registerDto)
    {
        try
        {
            var response = await _authService.RegisterAsync(registerDto);
            
            // Configurar cookie con el token JWT
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true, // HTTPS en producción
                SameSite = SameSiteMode.Strict,
                Expires = response.ExpiresAt
            };
            
            Response.Cookies.Append("jwt_token", response.Token, cookieOptions);
            
            // No devolver el token en el response por seguridad
            return Ok(new { usuario = response.Usuario, expiresAt = response.ExpiresAt });
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Intento de registro fallido para: {Email}", LogSanitizer.SanitizeEmail(registerDto.Email));
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en registro para: {Email}", LogSanitizer.SanitizeEmail(registerDto.Email));
            return StatusCode(500, new { error = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Cerrar sesión
    /// </summary>
    [HttpPost("logout")]
    [Authorize]
    public IActionResult Logout()
    {
        try
        {
            // Eliminar cookie del token
            Response.Cookies.Delete("jwt_token");
            
            _logger.LogInformation("Usuario cerró sesión exitosamente");
            return Ok(new { message = "Sesión cerrada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en logout");
            return StatusCode(500, new { error = "Error al cerrar sesión" });
        }
    }

    /// <summary>
    /// Verificar si el token es válido
    /// </summary>
    [HttpGet("verify")]
    [Authorize]
    public async Task<ActionResult<UsuarioDto>> VerifyToken()
    {
        try
        {
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized(new { error = "Token inválido" });
            }

            var usuario = await _authService.GetUserByIdAsync(userId);
            if (usuario == null)
            {
                return Unauthorized(new { error = "Usuario no encontrado" });
            }

            return Ok(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verificando token");
            return StatusCode(500, new { error = "Error verificando autenticación" });
        }
    }

    /// <summary>
    /// Cambiar contraseña
    /// </summary>
    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword(ChangePasswordDto changePasswordDto)
    {
        try
        {
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized(new { error = "Token inválido" });
            }

            await _authService.ChangePasswordAsync(userId, changePasswordDto);
            
            _logger.LogInformation("Usuario {UserId} cambió contraseña exitosamente", userId);
            return Ok(new { message = "Contraseña cambiada exitosamente" });
        }
        catch (UnauthorizedAccessException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cambiando contraseña");
            return StatusCode(500, new { error = "Error cambiando contraseña" });
        }
    }

    /// <summary>
    /// Migrar contraseñas de texto plano a BCrypt (SOLO EJECUTAR UNA VEZ)
    /// </summary>
    [HttpPost("migrate-passwords")]
    [AllowAnonymous] // Temporal para migración inicial
    public async Task<IActionResult> MigratePasswords()
    {
        try
        {
            var migratedCount = await _passwordMigrationService.MigratePlaintextPasswordsAsync();
            
            return Ok(new { 
                message = "Migración completada", 
                migratedPasswords = migratedCount 
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en migración de contraseñas");
            return StatusCode(500, new { error = "Error en migración de contraseñas" });
        }
    }
}