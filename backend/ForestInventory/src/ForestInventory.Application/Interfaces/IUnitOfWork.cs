namespace ForestInventory.Application.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IArbolRepository ArbolRepository { get; }
    IParcelaRepository ParcelaRepository { get; }
    IEspecieRepository EspecieRepository { get; }
    IUsuarioRepository UsuarioRepository { get; }
    ISyncLogRepository SyncLogRepository { get; }
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}
