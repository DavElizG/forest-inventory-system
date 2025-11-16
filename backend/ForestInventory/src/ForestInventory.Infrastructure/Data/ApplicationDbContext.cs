using ForestInventory.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace ForestInventory.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Arbol> Arboles => Set<Arbol>();
    public DbSet<Parcela> Parcelas => Set<Parcela>();
    public DbSet<Especie> Especies => Set<Especie>();
    public DbSet<SyncLog> SyncLogs => Set<SyncLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Enable PostGIS extension for spatial data
        modelBuilder.HasPostgresExtension("postgis");

        // Apply all configurations from the current assembly
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}
