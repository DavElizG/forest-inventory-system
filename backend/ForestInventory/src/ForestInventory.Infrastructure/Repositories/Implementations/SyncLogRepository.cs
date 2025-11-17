using ForestInventory.Domain.Entities;
using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class SyncLogRepository : Repository<SyncLog>, ISyncLogRepository
{
    public SyncLogRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<SyncLog>> GetByDispositivoAsync(string dispositivoId)
    {
        // Note: SyncLog entity uses UsuarioId, not DispositivoId
        // This method signature is kept for interface compatibility but may need revision
        return await FindAsync(s => s.UsuarioId.ToString() == dispositivoId);
    }

    public async Task<IEnumerable<SyncLog>> GetByFechaSincronizacionAsync(DateTime fecha)
    {
        return await FindAsync(s => s.FechaSincronizacion.Date == fecha.Date);
    }
}
