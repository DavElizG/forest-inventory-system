using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IParcelaService
{
    Task<IEnumerable<ParcelaDto>> GetAllParcelasAsync();
    Task<ParcelaDto?> GetParcelaByIdAsync(Guid id);
    Task<IEnumerable<ParcelaDto>> GetParcelasByUsuarioAsync(Guid usuarioId);
    Task<ParcelaDto> CreateParcelaAsync(CreateParcelaDto dto);
    Task<bool> UpdateParcelaAsync(Guid id, UpdateParcelaDto dto);
    Task<bool> DeleteParcelaAsync(Guid id);
    Task<IEnumerable<ParcelaDto>> GetParcelasByCodigoAsync(string codigo);
}
