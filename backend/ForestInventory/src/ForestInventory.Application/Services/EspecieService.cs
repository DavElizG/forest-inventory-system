using ForestInventory.Application.DTOs;
using ForestInventory.Application.Interfaces;
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

    public Task<IEnumerable<EspecieDto>> GetAllEspeciesAsync()
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }

    public Task<EspecieDto?> GetEspecieByIdAsync(Guid id)
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }

    public Task<EspecieDto> CreateEspecieAsync(CreateEspecieDto dto)
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }

    public Task<bool> UpdateEspecieAsync(Guid id, UpdateEspecieDto dto)
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }

    public Task<bool> DeleteEspecieAsync(Guid id)
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }

    public Task<IEnumerable<EspecieDto>> GetEspeciesByFamiliaAsync(string familia)
    {
        throw new NotImplementedException("Service methods need to be implemented based on actual entity structure");
    }
}
