namespace ForestInventory.Application.Services;

public static class CalculadoraForestalService
{
    public static double CalcularAreaBasal(double dap)
    {
        // AB = π * (DAP/2)² / 10000
        return Math.PI * Math.Pow(dap / 2, 2) / 10000;
    }

    public static double CalcularVolumen(double dap, double altura, double factorForma = 0.7)
    {
        var areaBasal = CalcularAreaBasal(dap);
        return areaBasal * altura * factorForma;
    }

    public static double CalcularBiomasa(double volumen, double densidadMadera)
    {
        // Biomasa = Volumen * Densidad
        return volumen * densidadMadera;
    }

    public static double CalcularCarbono(double biomasa, double factorCarbono = 0.5)
    {
        // Carbono = Biomasa * Factor (típicamente 0.5)
        return biomasa * factorCarbono;
    }

    public static double CalcularCO2Equivalente(double carbono)
    {
        // CO2 = Carbono * (44/12) - relación molecular
        return carbono * (44.0 / 12.0);
    }
}
