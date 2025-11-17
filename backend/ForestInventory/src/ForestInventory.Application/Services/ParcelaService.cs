using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
using ForestInventory.Domain.Entities;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace ForestInventory.Application.Services;

public class ParcelaService : IParcelaService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<ParcelaService> _logger;

    public ParcelaService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<ParcelaService> logger)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<IEnumerable<ParcelaDto>> GetAllParcelasAsync()
    {
        try
        {
            _logger.LogInformation("Getting all parcelas");
            var parcelas = await _unitOfWork.ParcelaRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<ParcelaDto>>(parcelas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all parcelas");
            throw;
        }
    }

    public async Task<ParcelaDto?> GetParcelaByIdAsync(Guid id)
    {
        try
        {
            var parcela = await _unitOfWork.ParcelaRepository.GetByIdAsync(id);
            return parcela == null ? null : _mapper.Map<ParcelaDto>(parcela);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting parcela by id: {ParcelaId}", id);
            throw;
        }
    }

    public async Task<IEnumerable<ParcelaDto>> GetParcelasByUsuarioAsync(Guid usuarioId)
    {
        try
        {
            var parcelas = await _unitOfWork.ParcelaRepository.GetByUsuarioAsync(usuarioId);
            return _mapper.Map<IEnumerable<ParcelaDto>>(parcelas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting parcelas by usuario: {UsuarioId}", usuarioId);
            throw;
        }
    }

    public async Task<ParcelaDto> CreateParcelaAsync(CreateParcelaDto dto)
    {
        try
        {
            _logger.LogInformation("Creating parcela: {Codigo}", dto.Codigo);

            var parcela = new Parcela
            {
                Codigo = dto.Codigo,
                Nombre = dto.Nombre,
                Latitud = dto.Latitud,
                Longitud = dto.Longitud,
                Altitud = dto.Altitud,
                Area = dto.Area,
                Descripcion = dto.Descripcion,
                Ubicacion = dto.Ubicacion,
                UsuarioCreadorId = dto.UsuarioCreadorId,
                FechaCreacion = DateTime.UtcNow,
                Activo = true
            };

            var createdParcela = await _unitOfWork.ParcelaRepository.AddAsync(parcela);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<ParcelaDto>(createdParcela);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating parcela: {Codigo}", dto.Codigo);
            throw;
        }
    }

    public async Task<bool> UpdateParcelaAsync(Guid id, UpdateParcelaDto dto)
    {
        try
        {
            var parcela = await _unitOfWork.ParcelaRepository.GetByIdAsync(id);
            if (parcela == null)
                return false;

            if (dto.Nombre != null) parcela.Nombre = dto.Nombre;
            if (dto.Codigo != null) parcela.Codigo = dto.Codigo;
            if (dto.Area.HasValue) parcela.Area = dto.Area.Value;
            if (dto.Descripcion != null) parcela.Descripcion = dto.Descripcion;
            if (dto.Ubicacion != null) parcela.Ubicacion = dto.Ubicacion;
            if (dto.Activo.HasValue) parcela.Activo = dto.Activo.Value;
            
            parcela.FechaUltimaActualizacion = DateTime.UtcNow;

            await _unitOfWork.ParcelaRepository.UpdateAsync(parcela);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating parcela: {ParcelaId}", id);
            throw;
        }
    }

    public async Task<bool> DeleteParcelaAsync(Guid id)
    {
        try
        {
            var parcela = await _unitOfWork.ParcelaRepository.GetByIdAsync(id);
            if (parcela == null)
                return false;

            await _unitOfWork.ParcelaRepository.DeleteAsync(parcela);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting parcela: {ParcelaId}", id);
            throw;
        }
    }

    public async Task<IEnumerable<ParcelaDto>> GetParcelasByCodigoAsync(string codigo)
    {
        try
        {
            var parcelas = await _unitOfWork.ParcelaRepository.FindAsync(p => p.Codigo.Contains(codigo));
            return _mapper.Map<IEnumerable<ParcelaDto>>(parcelas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting parcelas by codigo: {Codigo}", codigo);
            throw;
        }
    }
}
