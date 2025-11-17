using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IEspecieService
{
    Task<IEnumerable<EspecieDto>> GetAllEspeciesAsync();
    Task<EspecieDto?> GetEspecieByIdAsync(Guid id);
    Task<EspecieDto> CreateEspecieAsync(CreateEspecieDto dto);
    Task<bool> UpdateEspecieAsync(Guid id, UpdateEspecieDto dto);
    Task<bool> DeleteEspecieAsync(Guid id);
    Task<IEnumerable<EspecieDto>> GetEspeciesByFamiliaAsync(string familia);
}
