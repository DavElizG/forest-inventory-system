namespace ForestInventory.Application.DTOs;

public class ArbolDto
{
    public Guid Id { get; set; }
    public Guid ParcelaId { get; set; }
    public Guid EspecieId { get; set; }
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altura { get; set; }
    public double? Diametro { get; set; }
    public string? NombreLocal { get; set; }
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaUltimaActualizacion { get; set; }
}

public class CreateArbolDto
{
    public Guid ParcelaId { get; set; }
    public Guid EspecieId { get; set; }
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altura { get; set; }
    public double? Diametro { get; set; }
    public string? NombreLocal { get; set; }
    public string? Descripcion { get; set; }
}

public class UpdateArbolDto
{
    public Guid? EspecieId { get; set; }
    public double? Altura { get; set; }
    public double? Diametro { get; set; }
    public string? NombreLocal { get; set; }
    public string? Descripcion { get; set; }
    public bool? Activo { get; set; }
}
