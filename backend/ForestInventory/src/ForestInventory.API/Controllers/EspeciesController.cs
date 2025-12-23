using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;
using FluentValidation;

namespace ForestInventory.API.Controllers;

/// <summary>
/// Controlador para gestión de especies forestales
/// </summary>
/// <remarks>
/// Permisos de acceso:
/// - Administrador: Acceso completo
/// - Supervisor: Acceso completo
/// - TecnicoForestal: Acceso completo
/// - Consultor: Acceso completo (solo lectura recomendado)
/// </remarks>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EspeciesController : ControllerBase
{
    private readonly IEspecieService _especieService;
    private readonly ILogger<EspeciesController> _logger;
    private readonly IValidator<CreateEspecieDto> _createValidator;
    private readonly IValidator<UpdateEspecieDto> _updateValidator;

    public EspeciesController(
        IEspecieService especieService, 
        ILogger<EspeciesController> logger,
        IValidator<CreateEspecieDto> createValidator,
        IValidator<UpdateEspecieDto> updateValidator)
    {
        _especieService = especieService;
        _logger = logger;
        _createValidator = createValidator;
        _updateValidator = updateValidator;
    }

    /// <summary>
    /// Obtener todas las especies con paginación
    /// </summary>
    /// <param name="page">Número de página (inicia en 1)</param>
    /// <param name="pageSize">Tamaño de página (por defecto 20, máximo 100)</param>
    /// <response code="200">Lista de especies obtenida exitosamente</response>
    /// <response code="401">No autorizado - Token inválido o expirado</response>
    /// <response code="500">Error interno del servidor</response>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<EspecieDto>), 200)]
    [ProducesResponseType(401)]
    [ProducesResponseType(500)]
    public async Task<ActionResult<IEnumerable<EspecieDto>>> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        try
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            var (especies, totalCount) = await _especieService.GetAllEspeciesAsync(page, pageSize);
            
            Response.Headers.Append("X-Total-Count", totalCount.ToString());
            Response.Headers.Append("Access-Control-Expose-Headers", "X-Total-Count");
            
            return Ok(especies);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de especies");
            return StatusCode(500, new 
            { 
                message = "Error al obtener la lista de especies", 
                details = "Ha ocurrido un error al procesar su solicitud. Por favor, intente nuevamente."
            });
        }
    }

    /// <summary>
    /// Obtener especie por ID
    /// </summary>
    /// <response code="200">Especie encontrada</response>
    /// <response code="401">No autorizado - Token inválido o expirado</response>
    /// <response code="404">Especie no encontrada</response>
    /// <response code="500">Error interno del servidor</response>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(EspecieDto), 200)]
    [ProducesResponseType(401)]
    [ProducesResponseType(404)]
    [ProducesResponseType(500)]
    public async Task<ActionResult<EspecieDto>> GetById(Guid id)
    {
        try
        {
            var especie = await _especieService.GetEspecieByIdAsync(id);
            if (especie == null)
                return NotFound(new { message = "La especie solicitada no existe" });
            return Ok(especie);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener especie por ID: {Id}", id);
            return StatusCode(500, new 
            { 
                message = "Error al obtener la especie", 
                details = "Ha ocurrido un error al procesar su solicitud. Por favor, intente nuevamente."
            });
        }
    }

    /// <summary>
    /// Crear nueva especie
    /// </summary>
    /// <response code="201">Especie creada exitosamente</response>
    /// <response code="400">Datos de entrada inválidos</response>
    /// <response code="401">No autorizado - Token inválido o expirado</response>
    /// <response code="500">Error interno del servidor</response>
    [HttpPost]
    [ProducesResponseType(typeof(EspecieDto), 201)]
    [ProducesResponseType(400)]
    [ProducesResponseType(401)]
    [ProducesResponseType(500)]
    public async Task<ActionResult<EspecieDto>> Create(CreateEspecieDto dto)
    {
        try
        {
            // Validar con FluentValidation
            var validationResult = await _createValidator.ValidateAsync(dto);
            if (!validationResult.IsValid)
            {
                return BadRequest(new 
                { 
                    message = "Error de validación",
                    errors = validationResult.Errors.Select(e => new 
                    { 
                        field = e.PropertyName, 
                        message = e.ErrorMessage 
                    })
                });
            }

            var especie = await _especieService.CreateEspecieAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = especie.Id }, especie);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear especie");
            return StatusCode(500, new 
            { 
                message = "Error al crear la especie", 
                details = "Ha ocurrido un error al procesar su solicitud. Por favor, intente nuevamente."
            });
        }
    }

    /// <summary>
    /// Actualizar especie
    /// </summary>
    /// <response code="204">Especie actualizada exitosamente</response>
    /// <response code="400">Datos de entrada inválidos</response>
    /// <response code="401">No autorizado - Token inválido o expirado</response>
    /// <response code="404">Especie no encontrada</response>
    /// <response code="500">Error interno del servidor</response>
    [HttpPut("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(400)]
    [ProducesResponseType(401)]
    [ProducesResponseType(404)]
    [ProducesResponseType(500)]
    public async Task<IActionResult> Update(Guid id, UpdateEspecieDto dto)
    {
        try
        {
            // Validar con FluentValidation
            var validationResult = await _updateValidator.ValidateAsync(dto);
            if (!validationResult.IsValid)
            {
                return BadRequest(new 
                { 
                    message = "Error de validación",
                    errors = validationResult.Errors.Select(e => new 
                    { 
                        field = e.PropertyName, 
                        message = e.ErrorMessage 
                    })
                });
            }

            var result = await _especieService.UpdateEspecieAsync(id, dto);
            if (!result)
                return NotFound(new { message = "La especie solicitada no existe" });
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar especie");
            return StatusCode(500, new 
            { 
                message = "Error al actualizar la especie", 
                details = "Ha ocurrido un error al procesar su solicitud. Por favor, intente nuevamente."
            });
        }
    }

    /// <summary>
    /// Eliminar especie
    /// </summary>
    /// <response code="204">Especie eliminada exitosamente</response>
    /// <response code="401">No autorizado - Token inválido o expirado</response>
    /// <response code="404">Especie no encontrada</response>
    /// <response code="500">Error interno del servidor</response>
    [HttpDelete("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(401)]
    [ProducesResponseType(404)]
    [ProducesResponseType(500)]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var result = await _especieService.DeleteEspecieAsync(id);
            if (!result)
                return NotFound(new { message = "La especie solicitada no existe" });
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar especie");
            return StatusCode(500, new 
            { 
                message = "Error al eliminar la especie", 
                details = "Ha ocurrido un error al procesar su solicitud. Por favor, intente nuevamente."
            });
        }
    }
}
