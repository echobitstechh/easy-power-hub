import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/network/interceptors.dart';
import 'package:easyph/core/utils/config.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_response.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


enum HttpMethod { get, post, postRefresh, patch, put, delete }

class ApiService {
  final log = getLogger('ApiService');

  final Dio dio;

  ApiService() : dio = _dio();

  static final Map<String, String> _requestHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  static const int _timeout = 50000;

  static final _options = BaseOptions(
    baseUrl: AppConfig.baseUrl,
    headers: _requestHeaders,
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
  );

  static Dio _dio() {
    Dio dio;
    if (!kReleaseMode) {
      dio = Dio(_options)
        ..interceptors.add(logInterceptor)
        ..interceptors.add(requestInterceptors);
    } else {
      dio = Dio(_options)..interceptors.add(requestInterceptors);
    }
    return dio;
  }

  // Dio _dio() {
  //   Dio dio;
  //   if (!kReleaseMode) {
  //     dio = Dio(_options)
  //       ..interceptors.add(logInterceptor)
  //       ..interceptors.add(requestInterceptors);
  //   } else {
  //     dio = Dio(_options)..interceptors.add(requestInterceptors);
  //   }
  //   return dio;
  // }

  Future<ApiResponse> call({
    required HttpMethod method,
    required String endpoint,
    Map<String, dynamic>? reqBody,
    Map<String, dynamic>? reqParams,
    FormData? formData,
    bool protected = true,
    bool useFormData = false,
  }) async {
    try {
      switch (method) {
        case HttpMethod.post:
          Response response = await apiService.dio.post(
            endpoint,
            queryParameters: reqParams,
            data: useFormData ? formData : reqBody,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getToken()}"}),
          );
          return ApiResponse(response);


        case HttpMethod.postRefresh:
          Response response = await apiService.dio.post(
            endpoint,
            queryParameters: reqParams,
            data: useFormData ? formData : reqBody,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getRefreshToken()}"}),
          );
          return ApiResponse(response);

        case HttpMethod.get:
          Response response = await apiService.dio.get(
            queryParameters: reqParams,
            endpoint,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getToken()}"}),
          );
          return ApiResponse(response);
        case HttpMethod.patch:
          Response response = await apiService.dio.patch(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getToken()}"}),
          );
          return ApiResponse(response);
        case HttpMethod.put:
          Response response = await apiService.dio.put(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getToken()}"}),
          );
          return ApiResponse(response);
        case HttpMethod.delete:
          Response response = await apiService.dio.delete(
            endpoint,
            data: useFormData ? formData : reqBody,
            options: Options(
                headers: !protected
                    ? {}
                    : {"Authorization": "Bearer ${await _getToken()}"}),
          );
          return ApiResponse(response);

      }
    } on DioError catch (e) {
      log.e('DioError: ${e.message}');

      // Extract the response data
      final dynamic responseData = e.response?.data;

      // If the response data is a map, extract relevant fields
      if (responseData is Map) {
        final message = responseData['message'] ?? 'An error occurred';
        final statusCode = e.response?.statusCode ?? 500;

        return ApiResponse(
          Response(
            statusCode: statusCode,
            data: {
              'status': statusCode,
              'message': message,
              ...responseData, // Include the rest of the response
            },
            requestOptions: RequestOptions(path: endpoint),
          ),
        );
      }

      // Otherwise, handle as a plain string or generic error
      final statusCode = e.response?.statusCode ?? 500;
      final errorMessage = responseData?.toString() ?? 'An unexpected error occurred';

      return ApiResponse(
        Response(
          statusCode: statusCode,
          data: {
            'status': statusCode,
            'message': errorMessage,
          },
          requestOptions: RequestOptions(path: endpoint),
        ),
      );
    }catch (e) {
      // Handle unexpected errors
      return ApiResponse(
        Response(
          statusCode: 500,
          data: "An unexpected error occurred",
          requestOptions: RequestOptions(path: ''),
        ),
      );
    }
  }

  Future<String> _getToken() async {
    final localStorage = locator<LocalStorage>();
    String? token = await localStorage.fetch(LocalStorageDir.authToken);
    return token ?? "";
  }

  Future<String> _getRefreshToken() async {
    final localStorage = locator<LocalStorage>();
    String? token = await localStorage.fetch(LocalStorageDir.authRefreshToken);
    return token ?? "";
  }

  Future<ApiResponse> getFlutterWaveExchangeRate({
    required double amount,
    required String destinationCurrency,
    required String sourceCurrency,
  }) async {
    String endpoint = '${AppConfig.flutterWaveBaseUrl}/transfers/rates';
    Map<String, dynamic> reqParams = {
      'amount': amount.toString(),
      'destination_currency': destinationCurrency,
      'source_currency': sourceCurrency,
    };

    return await call(
      method: HttpMethod.get,
      endpoint: endpoint,
      reqParams: reqParams,
      // protected: true, // Assuming the API key is required for authentication
    );
  }
}
