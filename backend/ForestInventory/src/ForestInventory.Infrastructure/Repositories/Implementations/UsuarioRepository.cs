using ForestInventory.Domain.Entities;
using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class UsuarioRepository : Repository<Usuario>, IUsuarioRepository
{
    public UsuarioRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<Usuario?> GetByEmailAsync(string email)
    {
        return await _dbSet
            .FirstOrDefaultAsync(u => u.Email == email);
    }

    public async Task<IEnumerable<Usuario>> GetActivosAsync()
    {
        return await _dbSet
            .Where(u => u.Activo)
            .ToListAsync();
    }

    public async Task<bool> ExistsEmailAsync(string email)
    {
        return await _dbSet.AnyAsync(u => u.Email == email);
    }
}
