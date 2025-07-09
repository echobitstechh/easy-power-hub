
import 'package:dio/dio.dart';
import 'package:wahala_hq/core/data/repositories/repository_interface.dart';
import '../../../app/app.locator.dart';
import '../../../state.dart';
import '../../network/api_response.dart';
import '../../network/api_service.dart';

class Repository extends IRepository {
  final api = locator<ApiService>();


  @override
  Future<ApiResponse> login(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/login",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> refresh(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
        method: HttpMethod.postRefresh,
        endpoint: "auth/refresh_tokens",
        reqBody: req
    );
    return response;
  }

  @override
  Future<ApiResponse> logOut() async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/logout"
    );

    return response;
  }



  @override
  Future<ApiResponse> register(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/signup/with_email",
      reqBody: req,
    );

    return response;
  }


  @override
  Future<ApiResponse> verify(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/otp/email/verify",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> sendOtp(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/send_otp",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getProfile() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "auth/user/${profile.value.id}",
    );

    return response;
  }

  @override
  Future<ApiResponse> deleteAccount(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/delete",
      reqBody: req,
    );

    return response;
  }


  @override
  Future<ApiResponse> updateMedia(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "media/upload",
      useFormData: true,
      formData: FormData.fromMap(req),
    );

    return response;
  }



}
