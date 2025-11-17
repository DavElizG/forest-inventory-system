namespace ForestInventory.Application.DTOs;

public class UsuarioDto
{
    public Guid Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int Rol { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? UltimoAcceso { get; set; }
    public string? Telefono { get; set; }
    public string? Organizacion { get; set; }
}

public class CreateUsuarioDto
{
    public string NombreCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public int Rol { get; set; }
    public string? Telefono { get; set; }
    public string? Organizacion { get; set; }
}

public class UpdateUsuarioDto
{
    public string? NombreCompleto { get; set; }
    public string? Email { get; set; }
    public int? Rol { get; set; }
    public bool? Activo { get; set; }
    public string? Telefono { get; set; }
    public string? Organizacion { get; set; }
}
