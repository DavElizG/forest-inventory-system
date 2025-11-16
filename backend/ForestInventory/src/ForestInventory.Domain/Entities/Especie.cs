namespace ForestInventory.Domain.Entities;

public class Especie
{
    public Guid Id { get; set; }
    public string NombreComun { get; set; } = string.Empty;
    public string NombreCientifico { get; set; } = string.Empty;
    public string? Familia { get; set; }
    public string? Descripcion { get; set; }
    public double? DensidadMadera { get; set; } // kg/m³
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }

    // Navigation properties
    public ICollection<Arbol> Arboles { get; set; } = new List<Arbol>();
}
