using ForestInventory.Application.Common;
using ForestInventory.Application.Interfaces;
using Microsoft.Extensions.Logging;
using BCrypt.Net;

namespace ForestInventory.Application.Services;

public class PasswordMigrationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<PasswordMigrationService> _logger;

    public PasswordMigrationService(IUnitOfWork unitOfWork, ILogger<PasswordMigrationService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    /// <summary>
    /// Migra todas las contraseñas de texto plano a BCrypt hash
    /// SOLO EJECUTAR UNA VEZ después de implementar BCrypt
    /// </summary>
    public async Task<int> MigratePlaintextPasswordsAsync()
    {
        try
        {
            _logger.LogInformation("Iniciando migración de contraseñas a BCrypt hash");

            // Obtener todos los usuarios activos
            var usuarios = await _unitOfWork.UsuarioRepository.GetActivosAsync();
            int migratedCount = 0;

            foreach (var usuario in usuarios)
            {
                // Verificar si la contraseña ya está hasheada (BCrypt hashes empiezan con $2a$, $2b$, etc.)
                if (!usuario.PasswordHash.StartsWith("$2"))
                {
                    var plaintextPassword = usuario.PasswordHash;
                    
                    // Generar hash BCrypt
                    var hashedPassword = BCrypt.Net.BCrypt.HashPassword(plaintextPassword, BCrypt.Net.BCrypt.GenerateSalt());
                    
                    usuario.PasswordHash = hashedPassword;
                    await _unitOfWork.UsuarioRepository.UpdateAsync(usuario);
                    
                    migratedCount++;
                    _logger.LogInformation("Contraseña migrada para usuario: {Email}", LogSanitizer.SanitizeEmail(usuario.Email));
                }
            }

            await _unitOfWork.SaveChangesAsync();
            
            _logger.LogInformation("Migración completada. {Count} contraseñas migradas", migratedCount);
            return migratedCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error durante la migración de contraseñas");
            throw;
        }
    }
}