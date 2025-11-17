using ForestInventory.Infrastructure.Data;
using ForestInventory.Infrastructure.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore.Storage;
using AppInterfaces = ForestInventory.Application.Interfaces;

namespace ForestInventory.Infrastructure.Repositories.Implementations;

public class UnitOfWork : AppInterfaces.IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction? _transaction;

    public AppInterfaces.IArbolRepository ArbolRepository { get; }
    public AppInterfaces.IParcelaRepository ParcelaRepository { get; }
    public AppInterfaces.IEspecieRepository EspecieRepository { get; }
    public AppInterfaces.IUsuarioRepository UsuarioRepository { get; }
    public AppInterfaces.ISyncLogRepository SyncLogRepository { get; }

    public UnitOfWork(
        ApplicationDbContext context,
        IArbolRepository arbolRepository,
        IParcelaRepository parcelaRepository,
        IEspecieRepository especieRepository,
        IUsuarioRepository usuarioRepository,
        ISyncLogRepository syncLogRepository)
    {
        _context = context;
        ArbolRepository = arbolRepository;
        ParcelaRepository = parcelaRepository;
        EspecieRepository = especieRepository;
        UsuarioRepository = usuarioRepository;
        SyncLogRepository = syncLogRepository;
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
