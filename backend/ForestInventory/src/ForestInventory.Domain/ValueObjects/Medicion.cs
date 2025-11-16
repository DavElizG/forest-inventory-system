namespace ForestInventory.Domain.ValueObjects;

public class Medicion
{
    public double Dap { get; private set; } // Diámetro a la altura del pecho (cm)
    public double Altura { get; private set; } // Altura total (m)
    public double? AlturaComercial { get; private set; } // Altura comercial (m)
    public double? DiametroCopa { get; private set; } // Diámetro de copa (m)
    public DateTime FechaMedicion { get; private set; }

    public Medicion(
        double dap, 
        double altura, 
        double? alturaComercial = null, 
        double? diametroCopa = null,
        DateTime? fechaMedicion = null)
    {
        if (dap <= 0)
            throw new ArgumentException("El DAP debe ser mayor a 0", nameof(dap));

        if (altura <= 0)
            throw new ArgumentException("La altura debe ser mayor a 0", nameof(altura));

        if (alturaComercial.HasValue && alturaComercial.Value > altura)
            throw new ArgumentException("La altura comercial no puede ser mayor a la altura total", nameof(alturaComercial));

        Dap = dap;
        Altura = altura;
        AlturaComercial = alturaComercial;
        DiametroCopa = diametroCopa;
        FechaMedicion = fechaMedicion ?? DateTime.UtcNow;
    }

    public double CalcularAreaBasal()
    {
        // Área basal en m² = π * (DAP/2)² / 10000
        return Math.PI * Math.Pow(Dap / 2, 2) / 10000;
    }

    public double CalcularVolumen()
    {
        // Fórmula simplificada de Smalian: V = AB * H * 0.7 (factor de forma)
        return CalcularAreaBasal() * Altura * 0.7;
    }
}
