import '../../network/api_response.dart';
import 'package:dio/dio.dart';
abstract class IRepository {

  Future<ApiResponse> login(Map<String, dynamic> req);

  Future<ApiResponse> refresh(Map<String, dynamic> req);

  Future<ApiResponse> logOut();

  Future<ApiResponse> register(Map<String, dynamic> req);

  Future<ApiResponse> verify(Map<String, dynamic> req);

  Future<ApiResponse> sendOtp(Map<String, dynamic> req);

  Future<ApiResponse> getProfile();

  Future<ApiResponse> deleteAccount(Map<String, dynamic> req);

  Future<ApiResponse> updateMedia(Map<String, dynamic> req);

}
