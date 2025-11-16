namespace ForestInventory.Infrastructure.Repositories.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IArbolRepository Arboles { get; }
    IParcelaRepository Parcelas { get; }
    IEspecieRepository Especies { get; }
    IUsuarioRepository Usuarios { get; }
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}
