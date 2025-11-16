using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using DotEnv.Core;

namespace ForestInventory.Infrastructure.Data;

/// <summary>
/// Factory for creating ApplicationDbContext instances during design time (migrations).
/// This allows EF Core tools to create the context without having to run the full application.
/// </summary>
public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        // Load environment variables from .env file
        new EnvLoader().Load();

        // Get the connection string from environment variable
        var connectionString = Environment.GetEnvironmentVariable("DATABASE_CONNECTION_STRING");
        
        if (string.IsNullOrEmpty(connectionString))
        {
            throw new InvalidOperationException(
                "DATABASE_CONNECTION_STRING environment variable is not set. " +
                "Please ensure the .env file is in the backend/ForestInventory directory.");
        }

        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new ApplicationDbContext(optionsBuilder.Options);
    }
}
