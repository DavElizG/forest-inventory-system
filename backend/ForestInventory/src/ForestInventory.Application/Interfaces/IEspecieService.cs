using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IEspecieService
{
    Task<(IEnumerable<EspecieDto>, int totalCount)> GetAllEspeciesAsync(int page = 1, int pageSize = 20);
    Task<EspecieDto?> GetEspecieByIdAsync(Guid id);
    Task<EspecieDto> CreateEspecieAsync(CreateEspecieDto dto);
    Task<bool> UpdateEspecieAsync(Guid id, UpdateEspecieDto dto);
    Task<bool> DeleteEspecieAsync(Guid id);
    Task<IEnumerable<EspecieDto>> GetEspeciesByFamiliaAsync(string familia);
}
