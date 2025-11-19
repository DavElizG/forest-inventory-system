using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginDto loginDto);
    Task<LoginResponseDto> RegisterAsync(RegisterDto registerDto);
    Task<UsuarioDto?> GetUserByIdAsync(Guid userId);
    Task ChangePasswordAsync(Guid userId, ChangePasswordDto changePasswordDto);
    Task<string> GenerateJwtTokenAsync(UsuarioDto usuario);
    Task<bool> ValidateTokenAsync(string token);
    Task<string> AuthenticateAsync(string email, string password);
    Task<string> GeneratePasswordResetTokenAsync(string email);
    Task<bool> ResetPasswordAsync(string token, string newPassword);
}
