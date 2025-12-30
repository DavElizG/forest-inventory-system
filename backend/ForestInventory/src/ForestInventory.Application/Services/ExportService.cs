using System.Globalization;
using System.IO.Compression;
using System.Text;
using AutoMapper;
using CsvHelper;
using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace ForestInventory.Application.Services;

public class ExportService : IExportService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<ExportService> _logger;

    public ExportService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<ExportService> logger)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<byte[]> ExportArbolesToCsvAsync(Guid? parcelaId = null)
    {
        try
        {
            _logger.LogInformation("Iniciando exportación CSV de árboles. ParcelaId: {ParcelaId}", LogSanitizer.SanitizeGuid(parcelaId));

            var arboles = parcelaId.HasValue 
                ? await _unitOfWork.ArbolRepository.GetByParcelaAsync(parcelaId.Value)
                : await _unitOfWork.ArbolRepository.GetAllAsync();

            // Crear CSV
            using var memoryStream = new MemoryStream();
            using var writer = new StreamWriter(memoryStream, Encoding.UTF8);
            using var csv = new CsvWriter(writer, CultureInfo.InvariantCulture);

            // Escribir headers según formato Excel: fecha, noarb, nc, dap, hc, ht, obs
            csv.WriteField("fecha"); // Fecha de medición
            csv.WriteField("noarb"); // Número de árbol
            csv.WriteField("nc"); // Nombre común (especie)
            csv.WriteField("dap"); // Diámetro a altura del pecho
            csv.WriteField("hc"); // Altura comercial
            csv.WriteField("ht"); // Altura total
            csv.WriteField("obs"); // Observaciones
            csv.WriteField("POINT_X"); // Longitud
            csv.WriteField("POINT_Y"); // Latitud
            csv.NextRecord();

            // Escribir datos en el orden correcto
            foreach (var arbol in arboles)
            {
                csv.WriteField(arbol.FechaMedicion.ToString("yyyy-MM-dd")); // fecha
                csv.WriteField(arbol.NumeroArbol); // noarb
                csv.WriteField(arbol.Especie?.NombreComun ?? "Sin especie"); // nc (nombre común)
                csv.WriteField(arbol.Dap.ToString("F2")); // dap
                csv.WriteField(arbol.AlturaComercial?.ToString("F2") ?? ""); // hc
                csv.WriteField(arbol.Altura.ToString("F2")); // ht (altura total)
                csv.WriteField(arbol.Observaciones ?? ""); // obs
                csv.WriteField(arbol.Longitud.ToString("F8")); // POINT_X
                csv.WriteField(arbol.Latitud.ToString("F8")); // POINT_Y
                csv.NextRecord();
            }

            await writer.FlushAsync();
            
            _logger.LogInformation("Exportación CSV completada. {Count} árboles exportados", arboles.Count());
            return memoryStream.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a CSV");
            throw;
        }
    }

    public async Task<byte[]> ExportArbolesToExcelAsync(Guid? parcelaId = null)
    {
        // Por simplicidad, retornamos CSV (en producción se usaría EPPlus o similar)
        return await ExportArbolesToCsvAsync(parcelaId);
    }

    public async Task<string> ExportArbolesToKmlAsync(Guid? parcelaId = null)
    {
        try
        {
            _logger.LogInformation("Iniciando exportación KML de árboles. ParcelaId: {ParcelaId}", LogSanitizer.SanitizeGuid(parcelaId));

            var arboles = parcelaId.HasValue 
                ? await _unitOfWork.ArbolRepository.GetByParcelaAsync(parcelaId.Value)
                : await _unitOfWork.ArbolRepository.GetAllAsync();

            var arbolesConCoordenadas = arboles.Where(a => Math.Abs(a.Latitud) > 0.001 && Math.Abs(a.Longitud) > 0.001).ToList();

            var kmlBuilder = new StringBuilder();
            kmlBuilder.AppendLine("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            kmlBuilder.AppendLine("<kml xmlns=\"http://www.opengis.net/kml/2.2\">");
            kmlBuilder.AppendLine("  <Document>");
            kmlBuilder.AppendLine("    <name>Inventario Forestal - Árboles</name>");
            kmlBuilder.AppendLine("    <description>Datos de árboles del sistema de inventario forestal</description>");

            // Estilo para árboles
            kmlBuilder.AppendLine("    <Style id=\"arbolIcon\">");
            kmlBuilder.AppendLine("      <IconStyle>");
            kmlBuilder.AppendLine("        <color>ff00ff00</color>");
            kmlBuilder.AppendLine("        <scale>1.0</scale>");
            kmlBuilder.AppendLine("        <Icon>");
            kmlBuilder.AppendLine("          <href>http://maps.google.com/mapfiles/kml/shapes/parks.png</href>");
            kmlBuilder.AppendLine("        </Icon>");
            kmlBuilder.AppendLine("      </IconStyle>");
            kmlBuilder.AppendLine("    </Style>");

            foreach (var arbol in arbolesConCoordenadas)
            {
                kmlBuilder.AppendLine("    <Placemark>");
                kmlBuilder.AppendLine($"      <name>Árbol {arbol.Codigo}</name>");
                kmlBuilder.AppendLine("      <description><![CDATA[");
                kmlBuilder.AppendLine($"        <b>Especie:</b> {arbol.Especie?.NombreCientifico ?? "Sin especie"}<br/>");
                kmlBuilder.AppendLine($"        <b>DAP:</b> {arbol.Dap:F2} cm<br/>");
                kmlBuilder.AppendLine($"        <b>Altura:</b> {arbol.Altura:F2} m<br/>");
                if (arbol.AlturaComercial.HasValue)
                    kmlBuilder.AppendLine($"        <b>Altura Comercial:</b> {arbol.AlturaComercial:F2} m<br/>");
                kmlBuilder.AppendLine($"        <b>Estado:</b> {arbol.Estado}<br/>");
                kmlBuilder.AppendLine($"        <b>Fecha:</b> {arbol.FechaMedicion:yyyy-MM-dd}<br/>");
                if (!string.IsNullOrEmpty(arbol.Observaciones))
                    kmlBuilder.AppendLine($"        <b>Observaciones:</b> {arbol.Observaciones}<br/>");
                kmlBuilder.AppendLine("      ]]></description>");
                kmlBuilder.AppendLine("      <styleUrl>#arbolIcon</styleUrl>");
                kmlBuilder.AppendLine("      <Point>");
                kmlBuilder.AppendLine($"        <coordinates>{arbol.Longitud:F6},{arbol.Latitud:F6},{arbol.Altitud ?? 0}</coordinates>");
                kmlBuilder.AppendLine("      </Point>");
                kmlBuilder.AppendLine("    </Placemark>");
            }

            kmlBuilder.AppendLine("  </Document>");
            kmlBuilder.AppendLine("</kml>");

            _logger.LogInformation("Exportación KML completada. {Count} árboles exportados", arbolesConCoordenadas.Count);
            return kmlBuilder.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando árboles a KML");
            throw;
        }
    }

    public async Task<byte[]> ExportArbolesToKmzAsync(Guid? parcelaId = null)
    {
        try
        {
            var kmlContent = await ExportArbolesToKmlAsync(parcelaId);
            
            using var memoryStream = new MemoryStream();
            using var archive = new ZipArchive(memoryStream, ZipArchiveMode.Create, true);
            
            var kmlEntry = archive.CreateEntry("doc.kml");
            using var entryStream = kmlEntry.Open();
            using var writer = new StreamWriter(entryStream, Encoding.UTF8);
            
            await writer.WriteAsync(kmlContent);
            
            return memoryStream.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creando archivo KMZ");
            throw;
        }
    }

    public async Task<byte[]> ExportParcelasToKmzAsync()
    {
        try
        {
            _logger.LogInformation("Iniciando exportación KMZ de parcelas");

            var parcelas = await _unitOfWork.ParcelaRepository.GetAllAsync();
            var parcelasConCoordenadas = parcelas.Where(p => Math.Abs(p.Latitud) > 0.001 && Math.Abs(p.Longitud) > 0.001).ToList();

            var kmlBuilder = new StringBuilder();
            kmlBuilder.AppendLine("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            kmlBuilder.AppendLine("<kml xmlns=\"http://www.opengis.net/kml/2.2\">");
            kmlBuilder.AppendLine("  <Document>");
            kmlBuilder.AppendLine("    <name>Inventario Forestal - Parcelas</name>");

            // Estilo para parcelas
            kmlBuilder.AppendLine("    <Style id=\"parcelaIcon\">");
            kmlBuilder.AppendLine("      <IconStyle>");
            kmlBuilder.AppendLine("        <color>ff0000ff</color>");
            kmlBuilder.AppendLine("        <scale>1.2</scale>");
            kmlBuilder.AppendLine("        <Icon>");
            kmlBuilder.AppendLine("          <href>http://maps.google.com/mapfiles/kml/shapes/target.png</href>");
            kmlBuilder.AppendLine("        </Icon>");
            kmlBuilder.AppendLine("      </IconStyle>");
            kmlBuilder.AppendLine("    </Style>");

            foreach (var parcela in parcelasConCoordenadas)
            {
                var numeroArboles = parcela.Arboles?.Count ?? 0;
                
                kmlBuilder.AppendLine("    <Placemark>");
                kmlBuilder.AppendLine($"      <name>Parcela {parcela.Codigo}</name>");
                kmlBuilder.AppendLine("      <description><![CDATA[");
                kmlBuilder.AppendLine($"        <b>Código:</b> {parcela.Codigo}<br/>");
                kmlBuilder.AppendLine($"        <b>Nombre:</b> {parcela.Nombre}<br/>");
                kmlBuilder.AppendLine($"        <b>Área:</b> {parcela.Area:F2} ha<br/>");
                kmlBuilder.AppendLine($"        <b>Número de Árboles:</b> {numeroArboles}<br/>");
                kmlBuilder.AppendLine($"        <b>Fecha Creación:</b> {parcela.FechaCreacion:yyyy-MM-dd}<br/>");
                if (!string.IsNullOrEmpty(parcela.Descripcion))
                    kmlBuilder.AppendLine($"        <b>Descripción:</b> {parcela.Descripcion}<br/>");
                if (!string.IsNullOrEmpty(parcela.Ubicacion))
                    kmlBuilder.AppendLine($"        <b>Ubicación:</b> {parcela.Ubicacion}<br/>");
                kmlBuilder.AppendLine("      ]]></description>");
                kmlBuilder.AppendLine("      <styleUrl>#parcelaIcon</styleUrl>");
                kmlBuilder.AppendLine("      <Point>");
                kmlBuilder.AppendLine($"        <coordinates>{parcela.Longitud:F6},{parcela.Latitud:F6},{parcela.Altitud ?? 0}</coordinates>");
                kmlBuilder.AppendLine("      </Point>");
                kmlBuilder.AppendLine("    </Placemark>");
            }

            kmlBuilder.AppendLine("  </Document>");
            kmlBuilder.AppendLine("</kml>");

            // Crear KMZ
            using var memoryStream = new MemoryStream();
            using var archive = new ZipArchive(memoryStream, ZipArchiveMode.Create, true);
            
            var kmlEntry = archive.CreateEntry("doc.kml");
            using var entryStream = kmlEntry.Open();
            using var writer = new StreamWriter(entryStream, Encoding.UTF8);
            
            await writer.WriteAsync(kmlBuilder.ToString());
            
            _logger.LogInformation("Exportación KMZ de parcelas completada. {Count} parcelas exportadas", parcelasConCoordenadas.Count);
            return memoryStream.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exportando parcelas a KMZ");
            throw;
        }
    }

    public async Task<ExportSummaryDto> GetExportSummaryAsync()
    {
        try
        {
            var totalArboles = await _unitOfWork.ArbolRepository.CountAsync();
            var totalParcelas = await _unitOfWork.ParcelaRepository.CountAsync();
            var totalEspecies = await _unitOfWork.EspecieRepository.CountAsync();

            var arboles = await _unitOfWork.ArbolRepository.GetAllAsync();
            
            var arbolesPorEspecie = arboles
                .GroupBy(a => a.Especie?.NombreCientifico ?? "Sin especie")
                .ToDictionary(g => g.Key, g => g.Count());

            var arbolesPorParcela = arboles
                .GroupBy(a => a.Parcela?.Codigo ?? "Sin parcela")
                .ToDictionary(g => g.Key, g => g.Count());

            return new ExportSummaryDto
            {
                TotalArboles = totalArboles,
                TotalParcelas = totalParcelas,
                TotalEspecies = totalEspecies,
                ArbolesPorEspecie = arbolesPorEspecie,
                ArbolesPorParcela = arbolesPorParcela
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo resumen de exportación");
            throw;
        }
    }
}