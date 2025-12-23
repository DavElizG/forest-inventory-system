using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Domain.Entities;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace ForestInventory.Application.Services;

public class EspecieService : IEspecieService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<EspecieService> _logger;

    public EspecieService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<EspecieService> logger)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<(IEnumerable<EspecieDto>, int totalCount)> GetAllEspeciesAsync(int page = 1, int pageSize = 20)
    {
        try
        {
            _logger.LogInformation("Getting especies - Page: {Page}, PageSize: {PageSize}", page, pageSize);
            
            var allEspecies = await _unitOfWork.EspecieRepository.GetAllAsync();
            var totalCount = allEspecies.Count();
            
            var paginatedEspecies = allEspecies
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();
            
            var dtos = _mapper.Map<IEnumerable<EspecieDto>>(paginatedEspecies);
            
            return (dtos, totalCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all especies");
            throw;
        }
    }

    public async Task<EspecieDto?> GetEspecieByIdAsync(Guid id)
    {
        try
        {
            var especie = await _unitOfWork.EspecieRepository.GetByIdAsync(id);
            return especie == null ? null : _mapper.Map<EspecieDto>(especie);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting especie by id: {EspecieId}", id);
            throw;
        }
    }

    public async Task<EspecieDto> CreateEspecieAsync(CreateEspecieDto dto)
    {
        try
        {
            var especie = new Especie
            {
                NombreComun = dto.NombreComun,
                NombreCientifico = dto.NombreCientifico,
                Familia = dto.Familia,
                Descripcion = dto.Descripcion,
                DensidadMadera = dto.DensidadMadera,
                FechaCreacion = DateTime.UtcNow,
                Activo = true
            };

            var created = await _unitOfWork.EspecieRepository.AddAsync(especie);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<EspecieDto>(created);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating especie: {NombreCientifico}", LogSanitizer.SanitizeText(dto.NombreCientifico));
            throw;
        }
    }

    public async Task<bool> UpdateEspecieAsync(Guid id, UpdateEspecieDto dto)
    {
        try
        {
            var especie = await _unitOfWork.EspecieRepository.GetByIdAsync(id);
            if (especie == null)
                return false;

            if (dto.NombreComun != null) especie.NombreComun = dto.NombreComun;
            if (dto.Descripcion != null) especie.Descripcion = dto.Descripcion;
            if (dto.DensidadMadera.HasValue) especie.DensidadMadera = dto.DensidadMadera;
            if (dto.Activo.HasValue) especie.Activo = dto.Activo.Value;

            await _unitOfWork.EspecieRepository.UpdateAsync(especie);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating especie: {EspecieId}", id);
            throw;
        }
    }

    public async Task<bool> DeleteEspecieAsync(Guid id)
    {
        try
        {
            var especie = await _unitOfWork.EspecieRepository.GetByIdAsync(id);
            if (especie == null)
                return false;

            await _unitOfWork.EspecieRepository.DeleteAsync(especie);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting especie: {EspecieId}", id);
            throw;
        }
    }

    public async Task<IEnumerable<EspecieDto>> GetEspeciesByFamiliaAsync(string familia)
    {
        try
        {
            var especies = await _unitOfWork.EspecieRepository.GetByFamiliaAsync(familia);
            return _mapper.Map<IEnumerable<EspecieDto>>(especies);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting especies by familia: {Familia}", familia);
            throw;
        }
    }
}
