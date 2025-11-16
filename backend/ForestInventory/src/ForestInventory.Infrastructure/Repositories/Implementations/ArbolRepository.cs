using ForestInventory.Domain.Entities;
using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class ArbolRepository : Repository<Arbol>, IArbolRepository
{
    public ArbolRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Arbol>> GetByParcelaIdAsync(Guid parcelaId)
    {
        return await _dbSet
            .Where(a => a.ParcelaId == parcelaId)
            .Include(a => a.Especie)
            .Include(a => a.UsuarioCreador)
            .ToListAsync();
    }

    public async Task<IEnumerable<Arbol>> GetByEspecieIdAsync(Guid especieId)
    {
        return await _dbSet
            .Where(a => a.EspecieId == especieId)
            .Include(a => a.Parcela)
            .ToListAsync();
    }

    public async Task<IEnumerable<Arbol>> GetPendienteSincronizacionAsync()
    {
        return await _dbSet
            .Where(a => !a.Sincronizado)
            .Include(a => a.Especie)
            .Include(a => a.Parcela)
            .ToListAsync();
    }
}
