import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../utils/config.dart';
import '../utils/local_store_dir.dart';
import '../utils/local_stotage.dart';
import 'api_response.dart';
import 'interceptors.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Refactored Sept, 2025

enum HttpMethod { get, post, postRefresh, patch, put, delete }

class ApiService {
  final log = getLogger('ApiService');
  final Dio dio;

  ApiService() : dio = _createDio();

  // Default headers
  static final _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 20s feels safer than 50s (reduce perceived “freezing”)
  static const _timeout = Duration(seconds: 20);

  static final _options = BaseOptions(
    baseUrl: AppConfig.baseUrl,
    headers: _defaultHeaders,
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
  );

  static Dio _createDio() {
    final dio = Dio(_options);
    if (!kReleaseMode) {
      dio.interceptors.add(logInterceptor);
    }
    dio.interceptors.add(requestInterceptors);
    return dio;
  }

  Future<ApiResponse> call({
    required HttpMethod method,
    required String endpoint,
    dynamic reqBody,
    Map<String, dynamic>? reqParams,
    FormData? formData,
    bool protected = true,
    bool useFormData = false,
  }) async {
    try {

      final options = Options(headers: await _buildHeaders(protected: protected));


      late Response response;

      switch (method) {
        case HttpMethod.get:
          response = await dio.get(
            endpoint,
            queryParameters: reqParams,
            options: options,
          );
          break;
        case HttpMethod.post:
          response = await dio.post(
            endpoint,
            queryParameters: reqParams,
            data: useFormData ? formData : reqBody,
            options: options,
          );
          break;
        case HttpMethod.postRefresh:
          response = await dio.post(
            endpoint,
            queryParameters: reqParams,
            data: useFormData ? formData : reqBody,
            options: Options(
              headers: {"Authorization": "Bearer ${await _getRefreshToken()}"},
            ),
          );
          break;
        case HttpMethod.patch:
          response = await dio.patch(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: options,
          );
          break;
        case HttpMethod.put:
          response = await dio.put(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: options,
          );
          break;
        case HttpMethod.delete:
          response = await dio.delete(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: options,
          );
          break;
      }

      return ApiResponse(response);
    } on DioException catch (e) {
      log.e("API error: $e");


      // Graceful fallbacks
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return _timeoutResponse("Connection timeout");
        case DioExceptionType.sendTimeout:
          return _timeoutResponse("Send timeout");
        case DioExceptionType.receiveTimeout:
          return _timeoutResponse("Receive timeout");
        case DioExceptionType.badResponse:
          return ApiResponse(e.response!);
        case DioExceptionType.cancel:
          return _errorResponse(499, "Request cancelled");
        case DioExceptionType.unknown:
        default:
          return _errorResponse(101, "Network is unreachable");
      }
    }
  }

  // Helpers for consistent fallback responses
  ApiResponse _timeoutResponse(String message) => ApiResponse(
    Response(
      statusCode: 504,
      data: message,
      requestOptions: RequestOptions(path: ''),
    ),
  );

  ApiResponse _errorResponse(int code, String message) => ApiResponse(
    Response(
      statusCode: code,
      data: message,
      requestOptions: RequestOptions(path: ''),
    ),
  );

  Future<Map<String, dynamic>> _buildHeaders({bool protected = true, bool refresh = false}) async {
    if (!protected) return {};
    return {
      "Authorization": "Bearer ${refresh ? await _getRefreshToken() : await _getToken()}"
    };
  }


  Future<String> _getToken() async {
    final localStorage = locator<LocalStorage>();
    return await localStorage.fetch(LocalStorageDir.authToken) ?? "";
  }

  Future<String> _getRefreshToken() async {
    final localStorage = locator<LocalStorage>();
    return await localStorage.fetch(LocalStorageDir.authRefreshToken) ?? "";
  }
}
