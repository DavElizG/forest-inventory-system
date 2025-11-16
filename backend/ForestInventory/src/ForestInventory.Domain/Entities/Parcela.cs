namespace ForestInventory.Domain.Entities;

public class Parcela
{
    public Guid Id { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altitud { get; set; }
    public double Area { get; set; } // hectáreas
    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaUltimaActualizacion { get; set; }
    public bool Activo { get; set; }

    // Foreign Keys
    public Guid UsuarioCreadorId { get; set; }

    // Navigation properties
    public Usuario UsuarioCreador { get; set; } = null!;
    public ICollection<Arbol> Arboles { get; set; } = new List<Arbol>();
}
