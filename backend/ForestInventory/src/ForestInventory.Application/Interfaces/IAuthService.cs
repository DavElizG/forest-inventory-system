namespace ForestInventory.Application.Interfaces;

public interface IAuthService
{
    Task<string> AuthenticateAsync(string email, string password);
    Task<bool> ValidateTokenAsync(string token);
    Task<string> GeneratePasswordResetTokenAsync(string email);
    Task<bool> ResetPasswordAsync(string token, string newPassword);
}
