using ForestInventory.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ForestInventory.Infrastructure.Data.Configurations;

public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.HasKey(u => u.Id);

        builder.Property(u => u.NombreCompleto)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(200);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.Property(u => u.PasswordHash)
            .IsRequired();

        builder.Property(u => u.Rol)
            .IsRequired();

        builder.Property(u => u.Activo)
            .HasDefaultValue(true);

        builder.Property(u => u.FechaCreacion)
            .IsRequired();

        builder.Property(u => u.Telefono)
            .HasMaxLength(50);

        builder.Property(u => u.Organizacion)
            .HasMaxLength(200);

        builder.HasMany(u => u.Parcelas)
            .WithOne(p => p.UsuarioCreador)
            .HasForeignKey(p => p.UsuarioCreadorId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.Arboles)
            .WithOne(a => a.UsuarioCreador)
            .HasForeignKey(a => a.UsuarioCreadorId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
