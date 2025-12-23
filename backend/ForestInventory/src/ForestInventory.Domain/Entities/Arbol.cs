using ForestInventory.Domain.Enums;

namespace ForestInventory.Domain.Entities;

public class Arbol
{
    public Guid Id { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public int NumeroArbol { get; set; } // Número secuencial del árbol dentro de la parcela
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Altitud { get; set; }
    public double Dap { get; set; } // Diámetro a la altura del pecho (cm)
    public double Altura { get; set; } // Altura total (m)
    public double? AlturaComercial { get; set; } // Altura comercial (m)
    public double? DiametroCopa { get; set; } // Diámetro de copa (m)
    public EstadoArbol Estado { get; set; }
    public string? Observaciones { get; set; }
    public DateTime FechaMedicion { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaUltimaActualizacion { get; set; }
    public bool Sincronizado { get; set; }
    public Guid? SyncId { get; set; }

    // Foreign Keys
    public Guid ParcelaId { get; set; }
    public Guid EspecieId { get; set; }
    public Guid UsuarioCreadorId { get; set; }

    // Navigation properties
    public Parcela Parcela { get; set; } = null!;
    public Especie Especie { get; set; } = null!;
    public Usuario UsuarioCreador { get; set; } = null!;

    // Calculated properties
    public double CalcularAreaBasal()
    {
        return Math.PI * Math.Pow(Dap / 2, 2) / 10000;
    }

    public double CalcularVolumen()
    {
        return CalcularAreaBasal() * Altura * 0.7;
    }
}
