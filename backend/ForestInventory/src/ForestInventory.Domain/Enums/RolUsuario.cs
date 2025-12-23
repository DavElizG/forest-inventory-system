namespace ForestInventory.Domain.Enums;

/// <summary>
/// Roles de usuario en el sistema de inventario forestal
/// </summary>
/// <remarks>
/// - Administrador: Acceso total al sistema web + app móvil. Gestión de usuarios.
/// - Supervisor: Acceso completo a app móvil. Liderazgo de equipos en campo. No gestiona usuarios.
/// - TecnicoForestal: Acceso básico a app móvil para captura de datos en campo.
/// - Consultor: Acceso de solo lectura para consultas y reportes.
/// </remarks>
public enum RolUsuario
{
    /// <summary>
    /// Administrador del sistema - Acceso total
    /// </summary>
    Administrador = 1,
    
    /// <summary>
    /// Supervisor de campo - Acceso completo a app móvil, sin gestión de usuarios
    /// </summary>
    Supervisor = 2,
    
    /// <summary>
    /// Técnico forestal - Captura de datos en campo
    /// </summary>
    TecnicoForestal = 3,
    
    /// <summary>
    /// Consultor - Solo lectura y reportes
    /// </summary>
    Consultor = 4
}
