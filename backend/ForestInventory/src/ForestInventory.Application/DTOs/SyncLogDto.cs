namespace ForestInventory.Application.DTOs;

public class SyncLogDto
{
    public Guid Id { get; set; }
    public string DispositivoId { get; set; } = string.Empty;
    public DateTime FechaSincronizacion { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public int RegistrosSincronizados { get; set; }
    public bool ExitosoSync { get; set; }
    public string? Mensaje { get; set; }
}

public class CreateSyncLogDto
{
    public string DispositivoId { get; set; } = string.Empty;
    public string Tipo { get; set; } = string.Empty;
    public int RegistrosSincronizados { get; set; }
    public bool ExitosoSync { get; set; }
    public string? Mensaje { get; set; }
}
