using ForestInventory.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ForestInventory.Infrastructure.Data.Configurations;

public class EspecieConfiguration : IEntityTypeConfiguration<Especie>
{
    public void Configure(EntityTypeBuilder<Especie> builder)
    {
        builder.HasKey(e => e.Id);

        builder.Property(e => e.NombreComun)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(e => e.NombreCientifico)
            .IsRequired()
            .HasMaxLength(200);

        builder.HasIndex(e => e.NombreCientifico)
            .IsUnique();

        builder.Property(e => e.Familia)
            .HasMaxLength(100);

        builder.Property(e => e.Descripcion)
            .HasMaxLength(1000);

        builder.Property(e => e.Activo)
            .HasDefaultValue(true);

        builder.Property(e => e.FechaCreacion)
            .IsRequired();

        builder.HasMany(e => e.Arboles)
            .WithOne(a => a.Especie)
            .HasForeignKey(a => a.EspecieId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
