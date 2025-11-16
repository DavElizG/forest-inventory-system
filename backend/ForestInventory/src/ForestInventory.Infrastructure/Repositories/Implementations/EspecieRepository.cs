using ForestInventory.Domain.Entities;
using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class EspecieRepository : Repository<Especie>, IEspecieRepository
{
    public EspecieRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<Especie?> GetByNombreCientificoAsync(string nombreCientifico)
    {
        return await _dbSet
            .FirstOrDefaultAsync(e => e.NombreCientifico == nombreCientifico);
    }

    public async Task<IEnumerable<Especie>> GetActivasAsync()
    {
        return await _dbSet
            .Where(e => e.Activo)
            .ToListAsync();
    }
}
