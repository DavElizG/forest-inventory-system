using ForestInventory.Application.Common;
using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Domain.Entities;
using ForestInventory.Domain.Enums;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace ForestInventory.Application.Services;

public class ArbolService : IArbolService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<ArbolService> _logger;

    public ArbolService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<ArbolService> logger)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<IEnumerable<ArbolDto>> GetAllArbolesAsync()
    {
        try
        {
            _logger.LogInformation("Getting all arboles");
            var arboles = await _unitOfWork.ArbolRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<ArbolDto>>(arboles);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all arboles");
            throw;
        }
    }

    public async Task<ArbolDto?> GetArbolByIdAsync(Guid id)
    {
        try
        {
            var arbol = await _unitOfWork.ArbolRepository.GetByIdAsync(id);
            return arbol == null ? null : _mapper.Map<ArbolDto>(arbol);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting arbol by id: {ArbolId}", id);
            throw;
        }
    }

    public async Task<IEnumerable<ArbolDto>> GetArbolesByParcelaAsync(Guid parcelaId)
    {
        try
        {
            var arboles = await _unitOfWork.ArbolRepository.GetByParcelaAsync(parcelaId);
            return _mapper.Map<IEnumerable<ArbolDto>>(arboles);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting arboles by parcela: {ParcelaId}", parcelaId);
            throw;
        }
    }

    public async Task<ArbolDto> CreateArbolAsync(CreateArbolDto dto)
    {
        try
        {
            _logger.LogInformation("Creating arbol in parcela: {ParcelaId}", LogSanitizer.SanitizeGuid(dto.ParcelaId));

            var arbol = new Arbol
            {
                Codigo = Guid.NewGuid().ToString().Substring(0, 8),
                NumeroArbol = dto.NumeroArbol,
                Latitud = dto.Latitud,
                Longitud = dto.Longitud,
                Altitud = 0,
                Dap = dto.Diametro ?? 0,
                Altura = dto.Altura ?? 0,
                AlturaComercial = 0,
                DiametroCopa = 0,
                Estado = EstadoArbol.Sano,
                Observaciones = dto.Descripcion,
                FechaMedicion = DateTime.UtcNow,
                ParcelaId = dto.ParcelaId,
                EspecieId = dto.EspecieId,
                UsuarioCreadorId = dto.UsuarioCreadorId,
                FechaCreacion = DateTime.UtcNow,
                Sincronizado = false
            };

            var createdArbol = await _unitOfWork.ArbolRepository.AddAsync(arbol);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<ArbolDto>(createdArbol);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating arbol in parcela: {ParcelaId}", LogSanitizer.SanitizeGuid(dto.ParcelaId));
            throw;
        }
    }

    public async Task<bool> UpdateArbolAsync(Guid id, UpdateArbolDto dto)
    {
        try
        {
            var arbol = await _unitOfWork.ArbolRepository.GetByIdAsync(id);
            if (arbol == null)
                return false;

            if (dto.Diametro.HasValue) arbol.Dap = dto.Diametro.Value;
            if (dto.Altura.HasValue) arbol.Altura = dto.Altura.Value;
            if (dto.Descripcion != null) arbol.Observaciones = dto.Descripcion;
            if (dto.EspecieId.HasValue) arbol.EspecieId = dto.EspecieId.Value;
            if (dto.Activo.HasValue) arbol.Sincronizado = dto.Activo.Value;
            
            arbol.FechaUltimaActualizacion = DateTime.UtcNow;

            await _unitOfWork.ArbolRepository.UpdateAsync(arbol);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating arbol: {ArbolId}", id);
            throw;
        }
    }

    public async Task<bool> DeleteArbolAsync(Guid id)
    {
        try
        {
            var arbol = await _unitOfWork.ArbolRepository.GetByIdAsync(id);
            if (arbol == null)
                return false;

            await _unitOfWork.ArbolRepository.DeleteAsync(arbol);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting arbol: {ArbolId}", id);
            throw;
        }
    }
}
