using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ForestInventory.Application.Common;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;

namespace ForestInventory.API.Controllers;

/// <summary>
/// Controlador para gestión de parcelas forestales
/// </summary>
/// <remarks>
/// Permisos de acceso:
/// - Administrador: Acceso completo
/// - Supervisor: Acceso completo (gestión de parcelas de campo)
/// - TecnicoForestal: Acceso completo (asignación de parcelas)
/// - Consultor: Acceso completo (solo lectura recomendado)
/// </remarks>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ParcelasController : ControllerBase
{
    private readonly IParcelaService _parcelaService;
    private readonly ILogger<ParcelasController> _logger;

    public ParcelasController(IParcelaService parcelaService, ILogger<ParcelasController> logger)
    {
        _parcelaService = parcelaService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener todas las parcelas
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ParcelaDto>>> GetAll()
    {
        try
        {
            var parcelas = await _parcelaService.GetAllParcelasAsync();
            return Ok(parcelas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de parcelas");
            return StatusCode(500, new { error = "Error al obtener parcelas", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener parcela por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ParcelaDto>> GetById(Guid id)
    {
        try
        {
            var parcela = await _parcelaService.GetParcelaByIdAsync(id);
            if (parcela == null)
                return NotFound();
            return Ok(parcela);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener parcela por ID: {Id}", id);
            return StatusCode(500, new { error = "Error al obtener parcela", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener parcelas por usuario
    /// </summary>
    [HttpGet("usuario/{usuarioId}")]
    public async Task<ActionResult<IEnumerable<ParcelaDto>>> GetByUsuario(Guid usuarioId)
    {
        try
        {
            var parcelas = await _parcelaService.GetParcelasByUsuarioAsync(usuarioId);
            return Ok(parcelas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener parcelas del usuario: {UsuarioId}", LogSanitizer.SanitizeGuid(usuarioId));
            return StatusCode(500, new { error = "Error al obtener parcelas del usuario", details = ex.Message });
        }
    }

    /// <summary>
    /// Crear nueva parcela
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ParcelaDto>> Create(CreateParcelaDto dto)
    {
        try
        {
            var parcela = await _parcelaService.CreateParcelaAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = parcela.Id }, parcela);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear parcela");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Actualizar parcela
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateParcelaDto dto)
    {
        try
        {
            var result = await _parcelaService.UpdateParcelaAsync(id, dto);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar parcela");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Eliminar parcela
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var result = await _parcelaService.DeleteParcelaAsync(id);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar parcela");
            return StatusCode(500, "Error interno del servidor");
        }
    }
}
