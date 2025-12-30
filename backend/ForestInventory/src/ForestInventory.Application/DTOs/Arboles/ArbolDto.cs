namespace ForestInventory.Application.DTOs;

public class ArbolDto
{
    public Guid Id { get; set; }
    public int NumeroArbol { get; set; }
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
    
    // Propiedades adicionales para exportación
    public string? EspecieNombre { get; set; }
    public string? ParcelaCodigo { get; set; }
    public double Dap { get; set; }
    public int NumeroTallos { get; set; }
    public string? EstadoSalud { get; set; }
    public DateTime FechaMedicion { get; set; }
    public string? Observaciones { get; set; }
}

public class CreateArbolDto
{
    public DateTime FechaMedicion { get; set; } // Fecha de medición (editable)
    public int NumeroArbol { get; set; } // noarb
    public Guid ParcelaId { get; set; }
    public Guid EspecieId { get; set; } // nc (nombre común)
    public Guid UsuarioCreadorId { get; set; }
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public double? Diametro { get; set; } // dap
    public double? AlturaComercial { get; set; } // hc
    public double? Altura { get; set; } // ht (altura total)
    public string? Descripcion { get; set; } // obs (observaciones)
    public string? NombreLocal { get; set; }
}

public class UpdateArbolDto
{
    public DateTime? FechaMedicion { get; set; }
    public Guid? EspecieId { get; set; }
    public double? Diametro { get; set; } // dap
    public double? AlturaComercial { get; set; } // hc
    public double? Altura { get; set; } // ht
    public string? NombreLocal { get; set; }
    public string? Descripcion { get; set; }
    public bool? Activo { get; set; }
}
