namespace ForestInventory.Application.Interfaces;

public interface IKmzExportService
{
    Task<byte[]> ExportArbolesToKmzAsync(IEnumerable<Guid> arbolIds);
    Task<byte[]> ExportParcelasToKmzAsync(IEnumerable<Guid> parcelaIds);
}
