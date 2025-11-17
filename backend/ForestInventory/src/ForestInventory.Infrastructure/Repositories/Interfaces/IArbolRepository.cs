using ForestInventory.Domain.Entities;
using ForestInventory.Application.Interfaces;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IArbolRepository : Application.Interfaces.IArbolRepository
{
    Task<IEnumerable<Arbol>> GetByEspecieIdAsync(Guid especieId);
    Task<IEnumerable<Arbol>> GetPendienteSincronizacionAsync();
}
