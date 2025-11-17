using ForestInventory.Domain.Entities;

namespace ForestInventory.Application.Interfaces;

public interface IArbolRepository : IRepository<Arbol>
{
    Task<IEnumerable<Arbol>> GetByParcelaAsync(Guid parcelaId);
    Task<IEnumerable<Arbol>> GetByParcelaIdAsync(Guid parcelaId);
}
