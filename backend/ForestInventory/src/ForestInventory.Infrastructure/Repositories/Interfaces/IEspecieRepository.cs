using ForestInventory.Domain.Entities;
using ForestInventory.Application.Interfaces;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IEspecieRepository : Application.Interfaces.IEspecieRepository
{
    Task<Especie?> GetByNombreCientificoAsync(string nombreCientifico);
    Task<IEnumerable<Especie>> GetActivasAsync();
}
