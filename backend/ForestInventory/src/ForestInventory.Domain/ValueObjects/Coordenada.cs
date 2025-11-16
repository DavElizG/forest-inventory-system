namespace ForestInventory.Domain.ValueObjects;

public class Coordenada
{
    public double Latitud { get; private set; }
    public double Longitud { get; private set; }
    public double? Altitud { get; private set; }

    public Coordenada(double latitud, double longitud, double? altitud = null)
    {
        if (latitud < -90 || latitud > 90)
            throw new ArgumentException("La latitud debe estar entre -90 y 90 grados", nameof(latitud));

        if (longitud < -180 || longitud > 180)
            throw new ArgumentException("La longitud debe estar entre -180 y 180 grados", nameof(longitud));

        Latitud = latitud;
        Longitud = longitud;
        Altitud = altitud;
    }

    public override string ToString()
    {
        return Altitud.HasValue 
            ? $"({Latitud}, {Longitud}, {Altitud}m)" 
            : $"({Latitud}, {Longitud})";
    }
}
