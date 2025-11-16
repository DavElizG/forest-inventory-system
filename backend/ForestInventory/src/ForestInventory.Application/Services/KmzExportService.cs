using ForestInventory.Application.Interfaces;

namespace ForestInventory.Application.Services;

public class KmzExportService : IKmzExportService
{
    public Task<byte[]> ExportArbolesToKmzAsync(IEnumerable<Guid> arbolIds)
    {
        // Implementation pending - will generate KML and compress to KMZ
        throw new NotImplementedException();
    }

    public Task<byte[]> ExportParcelasToKmzAsync(IEnumerable<Guid> parcelaIds)
    {
        // Implementation pending
        throw new NotImplementedException();
    }
}
