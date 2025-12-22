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
    /// <remarks>
    /// El token JWT se almacena automáticamente en una cookie HTTP-Only segura.
    /// No es necesario manejar el token manualmente desde el cliente.
    /// </remarks>
    /// <response code="200">Login exitoso. Cookie establecida.</response>
    /// <response code="401">Credenciales inválidas</response>
    [HttpPost("login")]
    [ProducesResponseType(typeof(SecureLoginResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<SecureLoginResponseDto>> Login(LoginDto loginDto)
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
            return Ok(new SecureLoginResponseDto 
            { 
                Usuario = response.Usuario, 
                ExpiresAt = response.ExpiresAt 
            });
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
    /// <remarks>
    /// El token JWT se almacena automáticamente en una cookie HTTP-Only segura.
    /// Después del registro exitoso, el usuario queda autenticado automáticamente.
    /// </remarks>
    /// <response code="200">Registro exitoso. Cookie establecida.</response>
    /// <response code="400">Datos inválidos o email ya registrado</response>
    [HttpPost("register")]
    [ProducesResponseType(typeof(SecureLoginResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<SecureLoginResponseDto>> Register(RegisterDto registerDto)
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
            return Ok(new SecureLoginResponseDto 
            { 
                Usuario = response.Usuario, 
                ExpiresAt = response.ExpiresAt,
                Message = "Registro exitoso. Token guardado en cookie segura."
            });
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
    /// <remarks>
    /// Elimina la cookie JWT y cierra la sesión del usuario.
    /// Requiere estar autenticado.
    /// </remarks>
    /// <response code="200">Sesión cerrada exitosamente</response>
    /// <response code="401">No autenticado</response>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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
    /// <remarks>
    /// Verifica que el token JWT en la cookie sea válido y devuelve la información del usuario.
    /// Útil para verificar la sesión actual sin hacer login nuevamente.
    /// </remarks>
    /// <response code="200">Token válido. Devuelve información del usuario</response>
    /// <response code="401">Token inválido o expirado</response>
    [HttpGet("verify")]
    [Authorize]
    [ProducesResponseType(typeof(UsuarioDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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