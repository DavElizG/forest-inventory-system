namespace ForestInventory.Application.Interfaces;

public interface IExcelExportService
{
    Task<byte[]> ExportArbolesToExcelAsync(IEnumerable<Guid> arbolIds);
    Task<byte[]> ExportParcelasToExcelAsync(IEnumerable<Guid> parcelaIds);
}
