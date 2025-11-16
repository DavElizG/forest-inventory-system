using ForestInventory.Application.Interfaces;

namespace ForestInventory.Application.Services;

public class AuthService : IAuthService
{
    public Task<string> AuthenticateAsync(string email, string password)
    {
        // Implementation pending - will include JWT token generation
        throw new NotImplementedException();
    }

    public Task<string> GeneratePasswordResetTokenAsync(string email)
    {
        // Implementation pending
        throw new NotImplementedException();
    }

    public Task<bool> ResetPasswordAsync(string token, string newPassword)
    {
        // Implementation pending
        throw new NotImplementedException();
    }

    public Task<bool> ValidateTokenAsync(string token)
    {
        // Implementation pending
        throw new NotImplementedException();
    }
}
