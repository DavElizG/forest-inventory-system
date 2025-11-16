namespace ForestInventory.Application.Interfaces;

public interface ISyncService
{
    Task<bool> SyncArbolesAsync(Guid usuarioId);
    Task<bool> SyncParcelasAsync(Guid usuarioId);
    Task<int> GetPendingSyncCountAsync(Guid usuarioId);
}
