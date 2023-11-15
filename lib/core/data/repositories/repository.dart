import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/core/data/repositories/repository_interface.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/core/network/api_service.dart';
import 'package:dio/dio.dart';

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
  Future<ApiResponse> register(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/signup",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> verify(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/verification",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getProducts() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "products/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getSellingFast() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/sellingfast",
    );

    return response;
  }

  @override
  Future<ApiResponse> getProfile() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "user/profile",
    );

    return response;
  }

  @override
  Future<ApiResponse> initTransaction(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
        method: HttpMethod.post, endpoint: "user/wallet/fund", reqBody: req);

    return response;
  }

  @override
  Future<ApiResponse> saveOrder(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "orders/save",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> verifyTransaction(String ref) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "transaction/verify?trxref=$ref&reference=$ref",
    );

    return response;
  }

  @override
  Future<ApiResponse> payForOrder(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "orders/pay",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> resetPasswordRequest(String email) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "auth/resetpassword/$email",
    );

    return response;
  }

  @override
  Future<ApiResponse> updatePassword(
      Map<String, dynamic> req, String email) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "user/resetpassword",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> requestDelete(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/requestdelete",
      reqBody: req,
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
  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/profile/picture",
      useFormData: true,
      formData: FormData.fromMap(req),
    );

    return response;
  }

  @override
  Future<ApiResponse> getAds() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getBanks() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "transaction/banks",
    );

    return response;
  }

  @override
  Future<ApiResponse> withdraw(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "transaction/createtransfer",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getOrderList() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "orders/user/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> raffleList() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/user/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> verifyName(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "transaction/verifyaccount",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getTransactions() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "transaction/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> recommendedProducts(String productId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "products/recommended/$productId",
    );

    return response;
  }

  @override
  Future<ApiResponse> getResourceList() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "resources/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> resetPassword(
      Map<String, dynamic> req, String email) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "auth/resetpassword/$email",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getNotifications(String userId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "event/user/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> saveShipping(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "user/saveshipping",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> setDefaultShipping(
      Map<String, dynamic> req, String id) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/setdefaultshipping/$id",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> deleteDefaultShipping(String id) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/delete_shipping/$id",
    );

    return response;
  }

  @override
  Future<ApiResponse> reviewOrder(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "orders/review/add",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateNotification(String eventId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "event/list/$eventId",
    );

    return response;
  }
}
