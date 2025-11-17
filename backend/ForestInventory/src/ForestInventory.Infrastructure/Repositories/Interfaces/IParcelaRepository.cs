using ForestInventory.Domain.Entities;
using ForestInventory.Application.Interfaces;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IParcelaRepository : Application.Interfaces.IParcelaRepository
{
    Task<IEnumerable<Parcela>> GetActivasAsync();
}
