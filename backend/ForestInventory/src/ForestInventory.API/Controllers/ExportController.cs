using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ForestInventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ExportController : ControllerBase
{
    private readonly IExportService _exportService;
    private readonly ILogger<ExportController> _logger;

    public ExportController(IExportService exportService, ILogger<ExportController> logger)
    {
        _exportService = exportService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener resumen de datos para exportación
    /// </summary>
    [HttpGet("summary")]
    public async Task<ActionResult<ExportSummaryDto>> GetExportSummary()
    {
        try
    {
            var summary = await _exportService.GetExportSummaryAsync();
            return Ok(summary);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo resumen de exportación");
            return StatusCode(500, new { error = "Error obteniendo resumen de exportación" });
        }
    }

    /// <summary>
    /// Exportar árboles a CSV
    /// </summary>
    [HttpGet("arboles/csv")]
    public async Task<IActionResult> ExportArbolesToCsv([FromQuery] Guid? parcelaId = null)
    {
        try
        {
            var csvData = await _exportService.ExportArbolesToCsvAsync(parcelaId);
            var fileName = $"arboles_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
            
            return File(csvData, "text/csv", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a CSV");
            return StatusCode(500, new { error = "Error exportando árboles a CSV" });
        }
    }

    /// <summary>
    /// Exportar árboles a Excel (CSV para simplicidad)
    /// </summary>
    [HttpGet("arboles/excel")]
    public async Task<IActionResult> ExportArbolesToExcel([FromQuery] Guid? parcelaId = null)
    {
        try
        {
            var excelData = await _exportService.ExportArbolesToExcelAsync(parcelaId);
            var fileName = $"arboles_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx";
            
            return File(excelData, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a Excel");
            return StatusCode(500, new { error = "Error exportando árboles a Excel" });
        }
    }

    /// <summary>
    /// Exportar árboles a KML
    /// </summary>
    [HttpGet("arboles/kml")]
    public async Task<IActionResult> ExportArbolesToKml([FromQuery] Guid? parcelaId = null)
    {
        try
        {
            var kmlContent = await _exportService.ExportArbolesToKmlAsync(parcelaId);
            var fileName = $"arboles_{DateTime.Now:yyyyMMdd_HHmmss}.kml";
            
            return File(System.Text.Encoding.UTF8.GetBytes(kmlContent), "application/vnd.google-earth.kml+xml", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a KML");
            return StatusCode(500, new { error = "Error exportando árboles a KML" });
        }
    }

    /// <summary>
    /// Exportar árboles a KMZ (KML comprimido)
    /// </summary>
    [HttpGet("arboles/kmz")]
    public async Task<IActionResult> ExportArbolesToKmz([FromQuery] Guid? parcelaId = null)
    {
        try
        {
            var kmzData = await _exportService.ExportArbolesToKmzAsync(parcelaId);
            var fileName = $"arboles_{DateTime.Now:yyyyMMdd_HHmmss}.kmz";
            
            return File(kmzData, "application/vnd.google-earth.kmz", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a KMZ");
            return StatusCode(500, new { error = "Error exportando árboles a KMZ" });
        }
    }

    /// <summary>
    /// Exportar parcelas a KMZ
    /// </summary>
    [HttpGet("parcelas/kmz")]
    public async Task<IActionResult> ExportParcelasToKmz()
    {
        try
        {
            var kmzData = await _exportService.ExportParcelasToKmzAsync();
            var fileName = $"parcelas_{DateTime.Now:yyyyMMdd_HHmmss}.kmz";
            
            return File(kmzData, "application/vnd.google-earth.kmz", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando parcelas a KMZ");
            return StatusCode(500, new { error = "Error exportando parcelas a KMZ" });
        }
    }

    /// <summary>
    /// Exportar todo en un ZIP con múltiples formatos
    /// </summary>
    [HttpGet("all")]
    public async Task<IActionResult> ExportAll()
    {
        try
        {
            using var memoryStream = new MemoryStream();
            using var archive = new System.IO.Compression.ZipArchive(memoryStream, System.IO.Compression.ZipArchiveMode.Create, true);

            // Exportar árboles CSV
            var csvArboles = await _exportService.ExportArbolesToCsvAsync();
            var csvEntry = archive.CreateEntry("arboles.csv");
            using (var entryStream = csvEntry.Open())
            {
                await entryStream.WriteAsync(csvArboles);
            }

            // Exportar árboles KMZ
            var kmzArboles = await _exportService.ExportArbolesToKmzAsync();
            var kmzArbolesEntry = archive.CreateEntry("arboles.kmz");
            using (var entryStream = kmzArbolesEntry.Open())
            {
                await entryStream.WriteAsync(kmzArboles);
            }

            // Exportar parcelas KMZ
            var kmzParcelas = await _exportService.ExportParcelasToKmzAsync();
            var kmzParcelasEntry = archive.CreateEntry("parcelas.kmz");
            using (var entryStream = kmzParcelasEntry.Open())
            {
                await entryStream.WriteAsync(kmzParcelas);
            }

            var fileName = $"inventario_forestal_completo_{DateTime.Now:yyyyMMdd_HHmmss}.zip";
            return File(memoryStream.ToArray(), "application/zip", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando datos completos");
            return StatusCode(500, new { error = "Error exportando datos completos" });
        }
    }
}