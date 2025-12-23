import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/config/environment.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal() {
    _dio = Dio();
  }

  late final Dio _dio;
  late final String baseUrl;
  
  // Exponer Dio para casos especiales como descargas de archivos
  Dio get dio => _dio;

  // Initialize API service with environment configuration
  void initialize() {
    baseUrl = Environment.apiBaseUrl;
    
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: Environment.apiTimeout),
      receiveTimeout: Duration(milliseconds: Environment.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
      // Enable cookies for JWT authentication
      extra: {
        'withCredentials': true,
      },
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[DIO] $object'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final customError = _handleDioError(error);
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: customError.toString(),
          ));
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: options,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: options,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        options: options,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  // Handle Dio errors
  Exception _handleDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.badResponse:
          String message = 'Request failed with status ${error.response?.statusCode}';
          if (error.response?.data != null) {
            try {
              final data = error.response!.data;
              if (data is Map<String, dynamic> && data.containsKey('error')) {
                message = data['error'].toString();
              }
            } catch (e) {
              // Use default message
            }
          }
          return Exception(message);
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return Exception('No internet connection');
          }
          return Exception('Network error: ${error.message}');
        default:
          return Exception('Unexpected error: ${error.message}');
      }
    }
    return Exception('Unexpected error: ${error.toString()}');
  }

  // Parse response data with error handling
  Map<String, dynamic> parseResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      try {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Invalid response format');
        }
      } catch (e) {
        throw Exception('Failed to parse response: ${e.toString()}');
      }
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  }
}