using ForestInventory.Domain.Enums;

namespace ForestInventory.Domain.Entities;

public class SyncLog
{
    public Guid Id { get; set; }
    public Guid UsuarioId { get; set; }
    public TipoSincronizacion Tipo { get; set; }
    public DateTime FechaSincronizacion { get; set; }
    public int RegistrosEnviados { get; set; }
    public int RegistrosRecibidos { get; set; }
    public bool Exitoso { get; set; }
    public string? MensajeError { get; set; }
    public string? Detalles { get; set; }

    // Navigation properties
    public Usuario Usuario { get; set; } = null!;
}
