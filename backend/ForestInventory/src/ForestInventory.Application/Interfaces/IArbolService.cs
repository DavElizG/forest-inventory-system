using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IArbolService
{
    Task<IEnumerable<ArbolDto>> GetAllArbolesAsync();
    Task<ArbolDto?> GetArbolByIdAsync(Guid id);
    Task<IEnumerable<ArbolDto>> GetArbolesByParcelaAsync(Guid parcelaId);
    Task<ArbolDto> CreateArbolAsync(CreateArbolDto dto);
    Task<bool> UpdateArbolAsync(Guid id, UpdateArbolDto dto);
    Task<bool> DeleteArbolAsync(Guid id);
}
