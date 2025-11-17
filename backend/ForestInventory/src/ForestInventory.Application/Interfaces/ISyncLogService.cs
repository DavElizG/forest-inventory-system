using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface ISyncLogService
{
    Task<IEnumerable<SyncLogDto>> GetAllSyncLogsAsync();
    Task<SyncLogDto?> GetSyncLogByIdAsync(Guid id);
    Task<IEnumerable<SyncLogDto>> GetSyncLogsByDispositivoAsync(string dispositivoId);
    Task<SyncLogDto> CreateSyncLogAsync(CreateSyncLogDto dto);
    Task<object> GetSyncStatisticsAsync();
}
