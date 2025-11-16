using ForestInventory.Application.Interfaces;

namespace ForestInventory.Application.Services;

public class SyncService : ISyncService
{
    public Task<int> GetPendingSyncCountAsync(Guid usuarioId)
    {
        // Implementation pending
        throw new NotImplementedException();
    }

    public Task<bool> SyncArbolesAsync(Guid usuarioId)
    {
        // Implementation pending - will handle offline/online sync
        throw new NotImplementedException();
    }

    public Task<bool> SyncParcelasAsync(Guid usuarioId)
    {
        // Implementation pending
        throw new NotImplementedException();
    }
}
