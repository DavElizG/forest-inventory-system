using ForestInventory.Domain.Entities;

namespace ForestInventory.Application.Interfaces;

public interface IParcelaRepository : IRepository<Parcela>
{
    Task<IEnumerable<Parcela>> GetByUsuarioAsync(Guid usuarioId);
    Task<IEnumerable<Parcela>> GetByUsuarioIdAsync(Guid usuarioId);
    Task<IEnumerable<Parcela>> GetByCodigoAsync(string codigo);
}
