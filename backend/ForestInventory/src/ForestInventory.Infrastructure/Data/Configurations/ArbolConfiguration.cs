using ForestInventory.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ForestInventory.Infrastructure.Data.Configurations;

public class ArbolConfiguration : IEntityTypeConfiguration<Arbol>
{
    public void Configure(EntityTypeBuilder<Arbol> builder)
    {
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Codigo)
            .IsRequired()
            .HasMaxLength(50);

        builder.HasIndex(a => new { a.ParcelaId, a.Codigo })
            .IsUnique();

        builder.Property(a => a.Latitud)
            .IsRequired()
            .HasPrecision(10, 7);

        builder.Property(a => a.Longitud)
            .IsRequired()
            .HasPrecision(10, 7);

        builder.Property(a => a.Altitud)
            .HasPrecision(10, 2);

        builder.Property(a => a.Dap)
            .IsRequired()
            .HasPrecision(10, 2);

        builder.Property(a => a.Altura)
            .IsRequired()
            .HasPrecision(10, 2);

        builder.Property(a => a.AlturaComercial)
            .HasPrecision(10, 2);

        builder.Property(a => a.DiametroCopa)
            .HasPrecision(10, 2);

        builder.Property(a => a.Estado)
            .IsRequired();

        builder.Property(a => a.Observaciones)
            .HasMaxLength(1000);

        builder.Property(a => a.FechaMedicion)
            .IsRequired();

        builder.Property(a => a.FechaCreacion)
            .IsRequired();

        builder.Property(a => a.Sincronizado)
            .HasDefaultValue(false);

        builder.HasOne(a => a.Parcela)
            .WithMany(p => p.Arboles)
            .HasForeignKey(a => a.ParcelaId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.Especie)
            .WithMany(e => e.Arboles)
            .HasForeignKey(a => a.EspecieId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.UsuarioCreador)
            .WithMany(u => u.Arboles)
            .HasForeignKey(a => a.UsuarioCreadorId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
