using System.Text.RegularExpressions;

namespace ForestInventory.Application.Common;

/// <summary>
/// Utilidad para sanitizar datos sensibles en logs, previniendo Log Forging y exposición de PII
/// </summary>
public static class LogSanitizer
{
    /// <summary>
    /// Sanitiza un email para logging, previniendo Log Forging
    /// Reemplaza caracteres especiales que podrían causar inyección en logs
    /// y enmascara parcialmente el email para proteger PII
    /// </summary>
    /// <param name="email">Email a sanitizar</param>
    /// <returns>Email sanitizado y parcialmente enmascarado</returns>
    public static string SanitizeEmail(string? email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return "[email-vacio]";
        }

        // Remover caracteres de control y newlines que podrían causar log forging
        var sanitized = Regex.Replace(email, @"[\r\n\t\f\v]", "");
        
        // Remover otros caracteres peligrosos
        sanitized = sanitized.Replace("\0", "");

        // Enmascarar parcialmente el email para proteger PII
        // Ejemplo: john.doe@example.com -> j***e@e*****e.com
        var parts = sanitized.Split('@');
        if (parts.Length == 2)
        {
            var localPart = parts[0];
            var domainPart = parts[1];

            // Enmascarar parte local (mantener primer y último caracter)
            if (localPart.Length > 2)
            {
                localPart = $"{localPart[0]}***{localPart[^1]}";
            }
            else if (localPart.Length == 2)
            {
                localPart = $"{localPart[0]}*";
            }
            else
            {
                localPart = "*";
            }

            // Enmascarar dominio (mantener primer y último caracter antes del TLD)
            var domainParts = domainPart.Split('.');
            if (domainParts.Length > 0 && domainParts[0].Length > 2)
            {
                domainParts[0] = $"{domainParts[0][0]}***{domainParts[0][^1]}";
            }
            else if (domainParts.Length > 0 && domainParts[0].Length == 2)
            {
                domainParts[0] = $"{domainParts[0][0]}*";
            }

            return $"{localPart}@{string.Join(".", domainParts)}";
        }

        // Si no tiene formato de email válido, enmascarar más agresivamente
        return sanitized.Length > 4 
            ? $"{sanitized[..2]}***{sanitized[^2..]}" 
            : "***";
    }

    /// <summary>
    /// Sanitiza un nombre para logging, previniendo Log Forging
    /// </summary>
    /// <param name="name">Nombre a sanitizar</param>
    /// <returns>Nombre sanitizado</returns>
    public static string SanitizeName(string? name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return "[nombre-vacio]";
        }

        // Remover caracteres de control y newlines
        return Regex.Replace(name, @"[\r\n\t\f\v\0]", "");
    }

    /// <summary>
    /// Sanitiza un GUID para logging
    /// </summary>
    /// <param name="guid">GUID a sanitizar</param>
    /// <returns>GUID sanitizado</returns>
    public static string SanitizeGuid(Guid? guid)
    {
        if (guid == null || guid == Guid.Empty)
        {
            return "[guid-vacio]";
        }

        // Los GUIDs son seguros, solo remover caracteres de control por si acaso
        var guidString = guid.Value.ToString();
        return Regex.Replace(guidString, @"[\r\n\t\f\v\0]", "");
    }

    /// <summary>
    /// Sanitiza texto genérico para logging
    /// </summary>
    /// <param name="text">Texto a sanitizar</param>
    /// <returns>Texto sanitizado</returns>
    public static string SanitizeText(string? text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return "[texto-vacio]";
        }

        // Remover caracteres de control y newlines, limitar longitud
        var sanitized = Regex.Replace(text, @"[\r\n\t\f\v\0]", "");
        return sanitized.Length > 100 ? sanitized[..100] + "..." : sanitized;
    }
}
