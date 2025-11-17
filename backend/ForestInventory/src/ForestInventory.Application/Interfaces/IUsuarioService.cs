using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Interfaces;

public interface IUsuarioService
{
    Task<IEnumerable<UsuarioDto>> GetAllUsuariosAsync();
    Task<UsuarioDto?> GetUsuarioByIdAsync(Guid id);
    Task<UsuarioDto> CreateUsuarioAsync(CreateUsuarioDto dto);
    Task<bool> UpdateUsuarioAsync(Guid id, UpdateUsuarioDto dto);
    Task<bool> DeleteUsuarioAsync(Guid id);
    Task<UsuarioDto?> GetUsuarioByEmailAsync(string email);
    Task<bool> ValidateCredentialsAsync(string email, string password);
}
