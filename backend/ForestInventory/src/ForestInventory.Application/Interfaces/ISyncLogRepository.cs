using ForestInventory.Domain.Entities;

namespace ForestInventory.Application.Interfaces;

public interface ISyncLogRepository : IRepository<SyncLog>
{
    Task<IEnumerable<SyncLog>> GetByDispositivoAsync(string dispositivoId);
    Task<IEnumerable<SyncLog>> GetByFechaSincronizacionAsync(DateTime fecha);
}
