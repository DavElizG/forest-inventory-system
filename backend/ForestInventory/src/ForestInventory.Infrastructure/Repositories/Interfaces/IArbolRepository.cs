using ForestInventory.Domain.Entities;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IArbolRepository : IRepository<Arbol>
{
    Task<IEnumerable<Arbol>> GetByParcelaIdAsync(Guid parcelaId);
    Task<IEnumerable<Arbol>> GetByEspecieIdAsync(Guid especieId);
    Task<IEnumerable<Arbol>> GetPendienteSincronizacionAsync();
}
