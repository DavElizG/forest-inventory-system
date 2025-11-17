using Microsoft.AspNetCore.Mvc;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;

namespace ForestInventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SyncLogsController : ControllerBase
{
    private readonly ISyncLogService _syncLogService;
    private readonly ILogger<SyncLogsController> _logger;

    public SyncLogsController(ISyncLogService syncLogService, ILogger<SyncLogsController> logger)
    {
        _syncLogService = syncLogService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener todos los logs de sincronización
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<SyncLogDto>>> GetAll()
    {
        try
        {
            var logs = await _syncLogService.GetAllSyncLogsAsync();
            return Ok(logs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener logs de sincronización");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Obtener log de sincronización por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<SyncLogDto>> GetById(Guid id)
    {
        try
        {
            var log = await _syncLogService.GetSyncLogByIdAsync(id);
            if (log == null)
                return NotFound();
            return Ok(log);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener log de sincronización");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Obtener logs de sincronización por dispositivo
    /// </summary>
    [HttpGet("dispositivo/{dispositivoId}")]
    public async Task<ActionResult<IEnumerable<SyncLogDto>>> GetByDispositivo(string dispositivoId)
    {
        try
        {
            var logs = await _syncLogService.GetSyncLogsByDispositivoAsync(dispositivoId);
            return Ok(logs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener logs por dispositivo");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Crear nuevo log de sincronización
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<SyncLogDto>> Create(CreateSyncLogDto dto)
    {
        try
        {
            var log = await _syncLogService.CreateSyncLogAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = log.Id }, log);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear log de sincronización");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Obtener estadísticas de sincronización
    /// </summary>
    [HttpGet("estadisticas/resumen")]
    public async Task<ActionResult> GetEstadisticas()
    {
        try
        {
            var stats = await _syncLogService.GetSyncStatisticsAsync();
            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener estadísticas");
            return StatusCode(500, "Error interno del servidor");
        }
    }
}
