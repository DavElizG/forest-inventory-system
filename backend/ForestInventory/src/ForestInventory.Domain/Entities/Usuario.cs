using ForestInventory.Domain.Enums;

namespace ForestInventory.Domain.Entities;

public class Usuario
{
    public Guid Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public RolUsuario Rol { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? UltimoAcceso { get; set; }
    public string? Telefono { get; set; }
    public string? Organizacion { get; set; }

    // Navigation properties
    public ICollection<Parcela> Parcelas { get; set; } = new List<Parcela>();
    public ICollection<Arbol> Arboles { get; set; } = new List<Arbol>();
}
