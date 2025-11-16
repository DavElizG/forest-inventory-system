using ForestInventory.Domain.Entities;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IUsuarioRepository : IRepository<Usuario>
{
    Task<Usuario?> GetByEmailAsync(string email);
    Task<IEnumerable<Usuario>> GetActivosAsync();
    Task<bool> ExistsEmailAsync(string email);
}
