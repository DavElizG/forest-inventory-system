using Microsoft.AspNetCore.Mvc;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;

namespace ForestInventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EspeciesController : ControllerBase
{
    private readonly IEspecieService _especieService;
    private readonly ILogger<EspeciesController> _logger;

    public EspeciesController(IEspecieService especieService, ILogger<EspeciesController> logger)
    {
        _especieService = especieService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener todas las especies
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<EspecieDto>>> GetAll()
    {
        try
        {
            var especies = await _especieService.GetAllEspeciesAsync();
            return Ok(especies);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de especies");
            return StatusCode(500, new { error = "Error al obtener especies", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener especie por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<EspecieDto>> GetById(Guid id)
    {
        try
        {
            var especie = await _especieService.GetEspecieByIdAsync(id);
            if (especie == null)
                return NotFound();
            return Ok(especie);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener especie por ID: {Id}", id);
            return StatusCode(500, new { error = "Error al obtener especie", details = ex.Message });
        }
    }

    /// <summary>
    /// Crear nueva especie
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<EspecieDto>> Create(CreateEspecieDto dto)
    {
        try
        {
            var especie = await _especieService.CreateEspecieAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = especie.Id }, especie);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear especie: {NombreComun}", dto.NombreComun);
            return StatusCode(500, new { error = "Error al crear especie", details = ex.Message });
        }
    }

    /// <summary>
    /// Actualizar especie
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateEspecieDto dto)
    {
        try
        {
            var result = await _especieService.UpdateEspecieAsync(id, dto);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar especie");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Eliminar especie
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var result = await _especieService.DeleteEspecieAsync(id);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar especie");
            return StatusCode(500, "Error interno del servidor");
        }
    }
}
