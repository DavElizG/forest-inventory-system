using ForestInventory.Application.Interfaces;

namespace ForestInventory.Application.Services;

public class ExcelExportService : IExcelExportService
{
    public Task<byte[]> ExportArbolesToExcelAsync(IEnumerable<Guid> arbolIds)
    {
        // Implementation pending - will use EPPlus or similar library
        throw new NotImplementedException();
    }

    public Task<byte[]> ExportParcelasToExcelAsync(IEnumerable<Guid> parcelaIds)
    {
        // Implementation pending
        throw new NotImplementedException();
    }
}
