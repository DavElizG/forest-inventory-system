using ForestInventory.Domain.Entities;
using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class ParcelaRepository : Repository<Parcela>, IParcelaRepository
{
    public ParcelaRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Parcela>> GetByUsuarioIdAsync(Guid usuarioId)
    {
        return await _dbSet
            .Where(p => p.UsuarioCreadorId == usuarioId)
            .Include(p => p.Arboles)
            .ToListAsync();
    }

    public async Task<Parcela?> GetByCodigoAsync(string codigo)
    {
        return await _dbSet
            .Include(p => p.Arboles)
            .FirstOrDefaultAsync(p => p.Codigo == codigo);
    }

    public async Task<IEnumerable<Parcela>> GetActivasAsync()
    {
        return await _dbSet
            .Where(p => p.Activo)
            .ToListAsync();
    }

    public async Task<IEnumerable<Parcela>> GetByUsuarioAsync(Guid usuarioId)
    {
        return await GetByUsuarioIdAsync(usuarioId);
    }

    async Task<IEnumerable<Parcela>> ForestInventory.Application.Interfaces.IParcelaRepository.GetByCodigoAsync(string codigo)
    {
        var parcela = await _dbSet
            .Include(p => p.Arboles)
            .FirstOrDefaultAsync(p => p.Codigo == codigo);
        
        return parcela != null ? new[] { parcela } : Array.Empty<Parcela>();
    }
}
