import 'package:dio/dio.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class ApiResponse {
  Response response;

  ApiResponse(this.response);

  dynamic _data;
  int? _statusCode;

  dynamic get data {
    _data = response.data;
    return _data;
  }

  int? get statusCode {
    _statusCode = response.statusCode;
    return _statusCode;
  }
}
