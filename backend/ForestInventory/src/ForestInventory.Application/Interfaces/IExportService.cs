using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IExportService
{
    Task<byte[]> ExportArbolesToCsvAsync(Guid? parcelaId = null);
    Task<byte[]> ExportArbolesToExcelAsync(Guid? parcelaId = null);
    Task<byte[]> ExportArbolesToKmzAsync(Guid? parcelaId = null);
    Task<byte[]> ExportParcelasToKmzAsync();
    Task<string> ExportArbolesToKmlAsync(Guid? parcelaId = null);
    Task<ExportSummaryDto> GetExportSummaryAsync();
}