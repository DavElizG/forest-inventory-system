using ForestInventory.Domain.Entities;

namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IParcelaRepository : IRepository<Parcela>
{
    Task<IEnumerable<Parcela>> GetByUsuarioIdAsync(Guid usuarioId);
    Task<Parcela?> GetByCodigoAsync(string codigo);
    Task<IEnumerable<Parcela>> GetActivasAsync();
}
