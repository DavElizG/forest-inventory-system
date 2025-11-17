import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor de Dio para manejar errores HTTP y mostrar mensajes amigables
class ApiErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorMessage = _parseError(err);
    
    _logger.e('Error de API: ${err.requestOptions.path}', error: errorMessage);

    // Modificar el error con un mensaje más amigable
    final friendlyError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(friendlyError);
  }

  /// Parsear el error del backend a un mensaje amigable
  String _parseError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión a Internet.';
      
      case DioExceptionType.sendTimeout:
        return 'No se pudo enviar la solicitud. Revisa tu conexión.';
      
      case DioExceptionType.receiveTimeout:
        return 'El servidor tardó demasiado en responder. Intenta de nuevo.';
      
      case DioExceptionType.badCertificate:
        return 'Certificado de seguridad inv\u00e1lido.';
      
      case DioExceptionType.badResponse:
        return _parseBadResponse(error.response);
      
      case DioExceptionType.cancel:
        return 'Solicitud cancelada por el usuario.';
      
      case DioExceptionType.connectionError:
        return 'Sin conexión a Internet. Verifica tu red.';
      
      case DioExceptionType.unknown:
        return _parseUnknownError(error);
    }
  }

  /// Parsear errores de respuesta del servidor (4xx, 5xx)
  String _parseBadResponse(Response? response) {
    if (response == null) {
      return 'Error desconocido del servidor.';
    }

    final statusCode = response.statusCode;
    final data = response.data;

    switch (statusCode) {
      case 400:
        // Bad Request - errores de validación
        if (data is Map) {
          // Backend ASP.NET Core suele devolver errores así:
          // { "errors": { "Email": ["El email es requerido"], "Password": [...] } }
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final errorMessages = <String>[];
            
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.map((m) => m.toString()));
              }
            });
            
            return errorMessages.isNotEmpty 
                ? errorMessages.join('\n') 
                : 'Datos inválidos. Verifica el formulario.';
          }
          
          // Formato alternativo: { "error": "mensaje" } o { "message": "mensaje" }
          if (data['error'] != null) {
            return data['error'].toString();
          }
          if (data['message'] != null) {
            return data['message'].toString();
          }
        }
        return 'Solicitud inválida. Verifica los datos enviados.';

      case 401:
        return 'No autorizado. Inicia sesión nuevamente.';

      case 403:
        return 'No tienes permisos para realizar esta acción.';

      case 404:
        return 'Recurso no encontrado.';

      case 409:
        // Conflict - ejemplo: email ya existe
        if (data is Map) {
          if (data['error'] != null) return data['error'].toString();
          if (data['message'] != null) return data['message'].toString();
        }
        return 'Conflicto. El registro ya existe.';

      case 422:
        // Unprocessable Entity - errores de validación
        if (data is Map && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            final messages = errors.values
                .expand((e) => e is List ? e : [e])
                .join('\n');
            return messages.isNotEmpty ? messages : 'Error de validación.';
          }
        }
        return 'Datos inválidos.';

      case 500:
        if (data is Map && data['error'] != null) {
          return 'Error del servidor: ${data['error']}';
        }
        return 'Error interno del servidor. Intenta más tarde.';

      case 502:
        return 'Servidor no disponible. Intenta más tarde.';

      case 503:
        return 'Servicio temporalmente no disponible.';

      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Error del servidor ($statusCode). Intenta más tarde.';
        }
        return 'Error en la solicitud ($statusCode).';
    }
  }

  /// Parsear errores desconocidos
  String _parseUnknownError(DioException error) {
    final originalError = error.error;
    
    if (originalError == null) {
      return 'Error desconocido. Intenta de nuevo.';
    }

    // Errores de red comunes
    final errorString = originalError.toString().toLowerCase();
    
    if (errorString.contains('socket')) {
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    }
    
    if (errorString.contains('failed host lookup')) {
      return 'No se pudo resolver el servidor. Verifica tu conexión.';
    }
    
    if (errorString.contains('network is unreachable')) {
      return 'Red no disponible. Verifica tu conexión WiFi o datos móviles.';
    }

    return 'Error: ${originalError.toString()}';
  }
}

/// Extension para facilitar el manejo de errores en las vistas
extension DioErrorExtension on DioException {
  /// Obtener mensaje amigable del error
  String get friendlyMessage {
    if (error is String) {
      return error as String;
    }
    return 'Error desconocido';
  }

  /// Verificar si es un error de red
  bool get isNetworkError {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError;
  }

  /// Verificar si es un error de autenticación
  bool get isAuthError {
    return response?.statusCode == 401 || response?.statusCode == 403;
  }

  /// Verificar si es un error de validación
  bool get isValidationError {
    return response?.statusCode == 400 || response?.statusCode == 422;
  }
}
