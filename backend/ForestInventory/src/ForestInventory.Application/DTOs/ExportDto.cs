namespace ForestInventory.Application.DTOs;

public class ExportSummaryDto
{
    public int TotalArboles { get; set; }
    public int TotalParcelas { get; set; }
    public int TotalEspecies { get; set; }
    public Dictionary<string, int> ArbolesPorEspecie { get; set; } = new();
    public Dictionary<string, int> ArbolesPorParcela { get; set; } = new();
}

public class ExportFilterDto
{
    public Guid? ParcelaId { get; set; }
    public string? Especie { get; set; }
    public DateTime? FechaDesde { get; set; }
    public DateTime? FechaHasta { get; set; }
    public bool IncluirInactivos { get; set; } = false;
}