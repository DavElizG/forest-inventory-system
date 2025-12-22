using System.ComponentModel.DataAnnotations;

namespace ForestInventory.Application.DTOs;

public class LoginDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public UsuarioDto Usuario { get; set; } = null!;
    public DateTime ExpiresAt { get; set; }
}

/// <summary>
/// Respuesta de login sin el token (solo se envía en cookie HTTP-Only)
/// </summary>
public class SecureLoginResponseDto
{
    public UsuarioDto Usuario { get; set; } = null!;
    public DateTime ExpiresAt { get; set; }
    public string Message { get; set; } = "Login exitoso. Token guardado en cookie segura.";
}

public class RefreshTokenDto
{
    public string RefreshToken { get; set; } = string.Empty;
}

public class ChangePasswordDto
{
    [Required]
    public string CurrentPassword { get; set; } = string.Empty;
    
    [Required]
    [MinLength(6)]
    public string NewPassword { get; set; } = string.Empty;
}

public class RegisterDto
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MinLength(8)]
    public string Password { get; set; } = string.Empty;
    
    [Required]
    [MinLength(3)]
    public string NombreCompleto { get; set; } = string.Empty;
    
    [Required]
    public string Rol { get; set; } = string.Empty;
}