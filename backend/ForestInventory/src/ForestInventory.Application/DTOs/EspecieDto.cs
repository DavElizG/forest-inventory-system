namespace ForestInventory.Application.DTOs;

public class EspecieDto
{
    public Guid Id { get; set; }
    public string NombreComun { get; set; } = string.Empty;
    public string NombreCientifico { get; set; } = string.Empty;
    public string? Familia { get; set; }
    public string? Descripcion { get; set; }
    public double? DensidadMadera { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}

public class CreateEspecieDto
{
    public string NombreComun { get; set; } = string.Empty;
    public string NombreCientifico { get; set; } = string.Empty;
    public string? Familia { get; set; }
    public string? Descripcion { get; set; }
    public double? DensidadMadera { get; set; }
}

public class UpdateEspecieDto
{
    public string? NombreComun { get; set; }
    public string? NombreCientifico { get; set; }
    public string? Familia { get; set; }
    public string? Descripcion { get; set; }
    public double? DensidadMadera { get; set; }
    public bool? Activo { get; set; }
}
