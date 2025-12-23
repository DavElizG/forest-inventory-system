using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;

namespace ForestInventory.API.Controllers;

/// <summary>
/// Controlador para gestión de árboles en el inventario
/// </summary>
/// <remarks>
/// Permisos de acceso:
/// - Administrador: Acceso completo
/// - Supervisor: Acceso completo (gestión de inventarios de campo)
/// - TecnicoForestal: Acceso completo (captura de datos)
/// - Consultor: Acceso completo (solo lectura recomendado)
/// </remarks>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ArbolesController : ControllerBase
{
    private readonly IArbolService _arbolService;
    private readonly ILogger<ArbolesController> _logger;

    public ArbolesController(IArbolService arbolService, ILogger<ArbolesController> logger)
    {
        _arbolService = arbolService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener todos los árboles
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ArbolDto>>> GetAll()
    {
        try
        {
            var arboles = await _arbolService.GetAllArbolesAsync();
            return Ok(arboles);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de árboles");
            return StatusCode(500, new { error = "Error al obtener árboles", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener árbol por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ArbolDto>> GetById(Guid id)
    {
        try
        {
            var arbol = await _arbolService.GetArbolByIdAsync(id);
            if (arbol == null)
                return NotFound();
            return Ok(arbol);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener árbol por ID: {Id}", id);
            return StatusCode(500, new { error = "Error al obtener árbol", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener árboles por parcela
    /// </summary>
    [HttpGet("parcela/{parcelaId}")]
    public async Task<ActionResult<IEnumerable<ArbolDto>>> GetByParcela(Guid parcelaId)
    {
        try
        {
            var arboles = await _arbolService.GetArbolesByParcelaAsync(parcelaId);
            return Ok(arboles);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener árboles por parcela: {ParcelaId}", parcelaId);
            return StatusCode(500, new { error = "Error al obtener árboles de la parcela", details = ex.Message });
        }
    }

    /// <summary>
    /// Crear nuevo árbol
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ArbolDto>> Create(CreateArbolDto dto)
    {
        try
        {
            var arbol = await _arbolService.CreateArbolAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = arbol.Id }, arbol);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear árbol");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Actualizar árbol
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateArbolDto dto)
    {
        try
        {
            var result = await _arbolService.UpdateArbolAsync(id, dto);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar árbol");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Eliminar árbol
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var result = await _arbolService.DeleteArbolAsync(id);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar árbol");
            return StatusCode(500, "Error interno del servidor");
        }
    }
}
