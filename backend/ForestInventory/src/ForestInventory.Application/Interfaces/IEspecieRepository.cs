using ForestInventory.Domain.Entities;

namespace ForestInventory.Application.Interfaces;

public interface IEspecieRepository : IRepository<Especie>
{
    Task<IEnumerable<Especie>> GetByFamiliaAsync(string familia);
}
