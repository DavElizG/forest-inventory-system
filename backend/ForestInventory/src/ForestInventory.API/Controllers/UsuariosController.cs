using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ForestInventory.Application.Interfaces;
using ForestInventory.Application.DTOs;

namespace ForestInventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Administrador")]
public class UsuariosController : ControllerBase
{
    private readonly IUsuarioService _usuarioService;
    private readonly ILogger<UsuariosController> _logger;

    public UsuariosController(IUsuarioService usuarioService, ILogger<UsuariosController> logger)
    {
        _usuarioService = usuarioService;
        _logger = logger;
    }

    /// <summary>
    /// Obtener todos los usuarios
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UsuarioDto>>> GetAll()
    {
        try
        {
            var usuarios = await _usuarioService.GetAllUsuariosAsync();
            return Ok(usuarios);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de usuarios");
            return StatusCode(500, new { error = "Error al obtener usuarios", details = ex.Message });
        }
    }

    /// <summary>
    /// Obtener usuario por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<UsuarioDto>> GetById(Guid id)
    {
        try
        {
            var usuario = await _usuarioService.GetUsuarioByIdAsync(id);
            if (usuario == null)
                return NotFound();
            return Ok(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener usuario por ID: {Id}", id);
            return StatusCode(500, new { error = "Error al obtener usuario", details = ex.Message });
        }
    }

    /// <summary>
    /// Crear nuevo usuario
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<UsuarioDto>> Create(CreateUsuarioDto dto)
    {
        try
        {
            var usuario = await _usuarioService.CreateUsuarioAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = usuario.Id }, usuario);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Error de validación al crear usuario");
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al crear usuario");
            return StatusCode(500, new { error = "Error al crear usuario", details = ex.Message });
        }
    }

    /// <summary>
    /// Actualizar usuario
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateUsuarioDto dto)
    {
        try
        {
            var result = await _usuarioService.UpdateUsuarioAsync(id, dto);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar usuario");
            return StatusCode(500, "Error interno del servidor");
        }
    }

    /// <summary>
    /// Eliminar usuario
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var result = await _usuarioService.DeleteUsuarioAsync(id);
            if (!result)
                return NotFound();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar usuario");
            return StatusCode(500, "Error interno del servidor");
        }
    }
}
