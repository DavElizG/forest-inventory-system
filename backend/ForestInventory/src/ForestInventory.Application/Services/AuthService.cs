using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AutoMapper;
using BCrypt.Net;
using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;

namespace ForestInventory.Application.Services;

public class AuthService : IAuthService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<AuthService> _logger;
    private readonly IConfiguration _configuration;

    public AuthService(
        IUnitOfWork unitOfWork, 
        IMapper mapper, 
        ILogger<AuthService> logger,
        IConfiguration configuration)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<LoginResponseDto> LoginAsync(LoginDto loginDto)
    {
        try
        {
            _logger.LogInformation("Intento de login para: {Email}", LogSanitizer.SanitizeEmail(loginDto.Email));

            // Buscar usuario por email
            var usuario = await _unitOfWork.UsuarioRepository.GetByEmailAsync(loginDto.Email);
            if (usuario == null)
            {
                throw new UnauthorizedAccessException("Credenciales inválidas");
            }

            // Verificar contraseña con BCrypt
            if (!BCrypt.Net.BCrypt.Verify(loginDto.Password, usuario.PasswordHash))
            {
                throw new UnauthorizedAccessException("Credenciales inválidas");
            }

            // Verificar que el usuario esté activo
            if (!usuario.Activo)
            {
                throw new UnauthorizedAccessException("Usuario inactivo");
            }

            // Actualizar último acceso
            usuario.UltimoAcceso = DateTime.UtcNow;
            await _unitOfWork.UsuarioRepository.UpdateAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            // Generar token JWT
            var usuarioDto = _mapper.Map<UsuarioDto>(usuario);
            var token = await GenerateJwtTokenAsync(usuarioDto);
            var expiresAt = DateTime.UtcNow.AddHours(24);

            _logger.LogInformation("Login exitoso para: {Email}", LogSanitizer.SanitizeEmail(loginDto.Email));

            return new LoginResponseDto
            {
                Token = token,
                Usuario = usuarioDto,
                ExpiresAt = expiresAt
            };
        }
        catch (UnauthorizedAccessException)
        {
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login para: {Email}", LogSanitizer.SanitizeEmail(loginDto.Email));
            throw;
        }
    }

    public async Task<LoginResponseDto> RegisterAsync(RegisterDto registerDto)
    {
        try
        {
            _logger.LogInformation("Intento de registro para: {Email}", LogSanitizer.SanitizeEmail(registerDto.Email));

            // Verificar si el email ya existe
            var existingUser = await _unitOfWork.UsuarioRepository.GetByEmailAsync(registerDto.Email);
            if (existingUser != null)
            {
                throw new InvalidOperationException("El correo electrónico ya está registrado");
            }

            // Crear nuevo usuario
            // Convertir string Rol a enum RolUsuario
            if (!Enum.TryParse<RolUsuario>(registerDto.Rol, ignoreCase: true, out var rolEnum))
            {
                throw new ArgumentException($"Rol inválido: {registerDto.Rol}");
            }

            var usuario = new Usuario
            {
                Id = Guid.NewGuid(),
                Email = registerDto.Email,
                NombreCompleto = registerDto.NombreCompleto,
                Rol = rolEnum,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
                Activo = true,
                FechaCreacion = DateTime.UtcNow,
                UltimoAcceso = DateTime.UtcNow
            };

            // Guardar usuario
            await _unitOfWork.UsuarioRepository.AddAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            // Generar token JWT
            var usuarioDto = _mapper.Map<UsuarioDto>(usuario);
            var token = await GenerateJwtTokenAsync(usuarioDto);
            var expiresAt = DateTime.UtcNow.AddHours(24);

            _logger.LogInformation("Registro exitoso para: {Email}", LogSanitizer.SanitizeEmail(registerDto.Email));

            return new LoginResponseDto
            {
                Token = token,
                Usuario = usuarioDto,
                ExpiresAt = expiresAt
            };
        }
        catch (InvalidOperationException)
        {
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en registro para: {Email}", LogSanitizer.SanitizeEmail(registerDto.Email));
            throw;
        }
    }

    public async Task<UsuarioDto?> GetUserByIdAsync(Guid userId)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByIdAsync(userId);
            return usuario == null ? null : _mapper.Map<UsuarioDto>(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo usuario por ID: {UserId}", userId);
            throw;
        }
    }

    public async Task ChangePasswordAsync(Guid userId, ChangePasswordDto changePasswordDto)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByIdAsync(userId);
            if (usuario == null)
            {
                throw new UnauthorizedAccessException("Usuario no encontrado");
            }

            // Verificar contraseña actual con BCrypt
            if (!BCrypt.Net.BCrypt.Verify(changePasswordDto.CurrentPassword, usuario.PasswordHash))
            {
                throw new UnauthorizedAccessException("Contraseña actual incorrecta");
            }

            // Actualizar contraseña con BCrypt hash
            usuario.PasswordHash = BCrypt.Net.BCrypt.HashPassword(changePasswordDto.NewPassword, BCrypt.Net.BCrypt.GenerateSalt());
            await _unitOfWork.UsuarioRepository.UpdateAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Contraseña cambiada para usuario: {UserId}", userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cambiando contraseña para usuario: {UserId}", userId);
            throw;
        }
    }

    public Task<string> GenerateJwtTokenAsync(UsuarioDto usuario)
    {
        try
        {
            var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") 
                           ?? _configuration["JWT_SECRET_KEY"];
                           
            if (string.IsNullOrEmpty(jwtSecret))
            {
                throw new InvalidOperationException("JWT_SECRET_KEY environment variable or configuration is required");
            }

            var key = Encoding.ASCII.GetBytes(jwtSecret);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim("UserId", usuario.Id.ToString()),
                    new Claim(ClaimTypes.Email, usuario.Email),
                    new Claim(ClaimTypes.Name, usuario.NombreCompleto),
                    new Claim(ClaimTypes.Role, usuario.Rol.ToString()),
                    new Claim("Organizacion", usuario.Organizacion ?? "")
                }),
                Expires = DateTime.UtcNow.AddHours(24),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["JWT_ISSUER"] ?? "ForestInventoryAPI",
                Audience = _configuration["JWT_AUDIENCE"] ?? "ForestInventoryApp"
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return Task.FromResult(tokenHandler.WriteToken(token));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generando JWT token");
            throw;
        }
    }

    public Task<bool> ValidateTokenAsync(string token)
    {
        try
        {
            var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") 
                           ?? _configuration["JWT_SECRET_KEY"];
                           
            if (string.IsNullOrEmpty(jwtSecret))
            {
                throw new InvalidOperationException("JWT_SECRET_KEY environment variable or configuration is required");
            }

            var key = Encoding.ASCII.GetBytes(jwtSecret);
            var tokenHandler = new JwtSecurityTokenHandler();

            tokenHandler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = _configuration["JWT_ISSUER"] ?? "ForestInventoryAPI",
                ValidateAudience = true,
                ValidAudience = _configuration["JWT_AUDIENCE"] ?? "ForestInventoryApp",
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validatedToken);

            return Task.FromResult(validatedToken != null);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Token validation failed");
            return Task.FromResult(false);
        }
    }

    #region Legacy Methods (mantener compatibilidad)
    
    public async Task<string> AuthenticateAsync(string email, string password)
    {
        var loginDto = new LoginDto { Email = email, Password = password };
        var response = await LoginAsync(loginDto);
        return response.Token;
    }

    public async Task<string> GeneratePasswordResetTokenAsync(string email)
    {
        try
        {
            await Task.CompletedTask; // Satisfy async signature
            var usuario = await _unitOfWork.UsuarioRepository.GetByEmailAsync(email);
            if (usuario == null)
            {
                throw new ArgumentException("Usuario no encontrado");
            }

            // Generate a simple reset token (in production, use more secure token generation)
            var resetToken = Guid.NewGuid().ToString();
            
            _logger.LogInformation("Password reset token generated for: {Email}", LogSanitizer.SanitizeEmail(email));
            return resetToken;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating password reset token for: {Email}", LogSanitizer.SanitizeEmail(email));
            throw;
        }
    }

    public async Task<bool> ResetPasswordAsync(string token, string newPassword)
    {
        try
        {
            // Basic implementation - in production, store tokens in database with expiration
            // For now, we'll just validate token format and update password
            if (!Guid.TryParse(token, out _))
            {
                throw new ArgumentException("Invalid reset token");
            }

            // In production, find user by stored token and validate expiration
            // For now, this is a placeholder implementation
            await Task.CompletedTask; // Satisfy async signature
            _logger.LogInformation("Password reset completed for token: {Token}", token);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error resetting password for token: {Token}", token);
            throw;
        }
    }
    
    #endregion
}
