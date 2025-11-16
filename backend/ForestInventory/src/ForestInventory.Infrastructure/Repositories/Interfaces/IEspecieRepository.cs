using ForestInventory.Domain.Entities;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IEspecieRepository : IRepository<Especie>
{
    Task<Especie?> GetByNombreCientificoAsync(string nombreCientifico);
    Task<IEnumerable<Especie>> GetActivasAsync();
}
