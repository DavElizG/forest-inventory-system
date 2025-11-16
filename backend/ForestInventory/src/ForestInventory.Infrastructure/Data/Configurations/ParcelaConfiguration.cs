using ForestInventory.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ForestInventory.Infrastructure.Data.Configurations;

public class ParcelaConfiguration : IEntityTypeConfiguration<Parcela>
{
    public void Configure(EntityTypeBuilder<Parcela> builder)
    {
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Codigo)
            .IsRequired()
            .HasMaxLength(50);

        builder.HasIndex(p => p.Codigo)
            .IsUnique();

        builder.Property(p => p.Nombre)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(p => p.Latitud)
            .IsRequired()
            .HasPrecision(10, 7);

        builder.Property(p => p.Longitud)
            .IsRequired()
            .HasPrecision(10, 7);

        builder.Property(p => p.Altitud)
            .HasPrecision(10, 2);

        builder.Property(p => p.Area)
            .IsRequired()
            .HasPrecision(10, 4);

        builder.Property(p => p.Descripcion)
            .HasMaxLength(1000);

        builder.Property(p => p.Ubicacion)
            .HasMaxLength(500);

        builder.Property(p => p.FechaCreacion)
            .IsRequired();

        builder.Property(p => p.Activo)
            .HasDefaultValue(true);

        builder.HasOne(p => p.UsuarioCreador)
            .WithMany(u => u.Parcelas)
            .HasForeignKey(p => p.UsuarioCreadorId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(p => p.Arboles)
            .WithOne(a => a.Parcela)
            .HasForeignKey(a => a.ParcelaId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
