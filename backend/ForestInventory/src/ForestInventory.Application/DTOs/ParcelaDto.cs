namespace ForestInventory.Application.DTOs;

public class ParcelaDto
{
    public Guid Id { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altitud { get; set; }
    public double Area { get; set; }
    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaUltimaActualizacion { get; set; }
    public bool Activo { get; set; }
    public Guid UsuarioCreadorId { get; set; }
}

public class CreateParcelaDto
{
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altitud { get; set; }
    public double Area { get; set; }
    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public Guid UsuarioCreadorId { get; set; }
}

public class UpdateParcelaDto
{
    public string? Codigo { get; set; }
    public string? Nombre { get; set; }
    public double? Area { get; set; }
    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public bool? Activo { get; set; }
}
