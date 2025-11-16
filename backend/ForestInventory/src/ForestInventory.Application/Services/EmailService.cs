using ForestInventory.Application.Interfaces;

namespace ForestInventory.Application.Services;

public class EmailService : IEmailService
{
    public Task SendEmailAsync(string to, string subject, string body)
    {
        // Implementation pending - will include SMTP configuration
        throw new NotImplementedException();
    }

    public Task SendPasswordResetEmailAsync(string to, string resetToken)
    {
        // Implementation pending
        throw new NotImplementedException();
    }

    public Task SendWelcomeEmailAsync(string to, string userName)
    {
        // Implementation pending
        throw new NotImplementedException();
    }
}
