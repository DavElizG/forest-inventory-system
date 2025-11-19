using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Domain.Entities;
using ForestInventory.Domain.Enums;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace ForestInventory.Application.Services;

public class UsuarioService : IUsuarioService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<UsuarioService> _logger;

    public UsuarioService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<UsuarioService> logger)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<IEnumerable<UsuarioDto>> GetAllUsuariosAsync()
    {
        try
        {
            var usuarios = await _unitOfWork.UsuarioRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<UsuarioDto>>(usuarios);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all usuarios");
            throw;
        }
    }

    public async Task<UsuarioDto?> GetUsuarioByIdAsync(Guid id)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByIdAsync(id);
            return usuario == null ? null : _mapper.Map<UsuarioDto>(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting usuario by id: {UsuarioId}", LogSanitizer.SanitizeGuid(id));
            throw;
        }
    }

    public async Task<UsuarioDto> CreateUsuarioAsync(CreateUsuarioDto dto)
    {
        try
        {
            var exists = await _unitOfWork.UsuarioRepository.ExistsEmailAsync(dto.Email);
            if (exists)
                throw new InvalidOperationException($"Email {dto.Email} already exists");

            var usuario = new Usuario
            {
                NombreCompleto = dto.NombreCompleto,
                Email = dto.Email,
                PasswordHash = dto.Password,
                Rol = (RolUsuario)dto.Rol,
                Telefono = dto.Telefono,
                Organizacion = dto.Organizacion,
                FechaCreacion = DateTime.UtcNow,
                Activo = true
            };

            var created = await _unitOfWork.UsuarioRepository.AddAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<UsuarioDto>(created);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating usuario: {Email}", LogSanitizer.SanitizeEmail(dto.Email));
            throw;
        }
    }

    public async Task<bool> UpdateUsuarioAsync(Guid id, UpdateUsuarioDto dto)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByIdAsync(id);
            if (usuario == null)
                return false;

            if (dto.NombreCompleto != null) usuario.NombreCompleto = dto.NombreCompleto;
            if (dto.Telefono != null) usuario.Telefono = dto.Telefono;
            if (dto.Organizacion != null) usuario.Organizacion = dto.Organizacion;
            if (dto.Activo.HasValue) usuario.Activo = dto.Activo.Value;

            await _unitOfWork.UsuarioRepository.UpdateAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating usuario: {UsuarioId}", LogSanitizer.SanitizeGuid(id));
            throw;
        }
    }

    public async Task<bool> DeleteUsuarioAsync(Guid id)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByIdAsync(id);
            if (usuario == null)
                return false;

            await _unitOfWork.UsuarioRepository.DeleteAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting usuario: {UsuarioId}", LogSanitizer.SanitizeGuid(id));
            throw;
        }
    }

    public async Task<UsuarioDto?> GetUsuarioByEmailAsync(string email)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByEmailAsync(email);
            return usuario == null ? null : _mapper.Map<UsuarioDto>(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting usuario by email: {Email}", LogSanitizer.SanitizeEmail(email));
            throw;
        }
    }

    public async Task<bool> ValidateCredentialsAsync(string email, string password)
    {
        try
        {
            var usuario = await _unitOfWork.UsuarioRepository.GetByEmailAsync(email);
            if (usuario == null || !usuario.Activo)
                return false;

            // TODO: Implement proper password verification with BCrypt
            return usuario.PasswordHash == password;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating credentials for email: {Email}", LogSanitizer.SanitizeEmail(email));
            throw;
        }
    }
}
