import 'package:easyph/app/app.locator.dart';
import 'package:easyph/core/data/repositories/repository_interface.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/core/network/api_service.dart';
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
  Future<ApiResponse> googleSignIn(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "oauth/auth/google",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> modifyCartItem(String productId, String action, {int? newFrequency}) async {
    final body = {
      "action": action,
      if (newFrequency != null) "newFrequency": newFrequency,
    };
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "cart/modify/$productId",
      reqBody: body,
    );
    return response;
  }



  @override
  Future<ApiResponse> requestOtp(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/initial-signup",
      reqBody: req,
    );

    return response;
  }
  @override
  Future<ApiResponse> submitOtp(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/verifySignupCode",
      reqBody: req,
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
  Future<ApiResponse> refresh(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
        method: HttpMethod.postRefresh,
        reqBody: req,
        endpoint: "auth/refresh-token"
    );
    return response;
  }

  @override
  Future<ApiResponse> register(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/finalSignup",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> verify(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/verify_otp",
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
  Future<ApiResponse> initializePayment(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "wallet/initializePayment",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getProducts({required int page, required int limit}) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "products",
      reqParams: {
        "page": page,
        "limit": limit,
      },
    );

    return response;
  }

  @override
  Future<ApiResponse> getProductTags() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "tags",
    );
    return response;
  }
  @override
  Future<ApiResponse> getProductsByTag({
    required String tagId,
    int page = 1,
    int limit = 10,
  }) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "products",
      reqParams: {
        "page": page,
        "limit": limit,
        "tag": tagId,
      },
    );
    return response;
  }

  @override
    Future<ApiResponse> getReviews( String productId) async {
      ApiResponse response = await api.call(
        method: HttpMethod.get,
        endpoint: "reviews/$productId",
      );

      return response;
    }

  @override
  Future<ApiResponse> getServices() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "/services",
    );

    return response;
  }

  @override
  Future<ApiResponse> getProjectComments(String projectId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "projects/$projectId/comments/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getProfile() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "profile",
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
      endpoint: "create",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> donateToProject(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "projects/donate",
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
      endpoint: "orders",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> categoryDiscounts(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "admin/category-discounts",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> convertToNaira(String amount) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "transaction/rates?amount=$amount",
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
  Future<ApiResponse> forgotPassword(
      Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/password-reset",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> newPassword(
      Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/update-password",
      reqBody: req,
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
  Future<ApiResponse> makeComment(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "projects/comment/new",
      reqBody: req,
    );

    return response;
  }


  @override
  Future<ApiResponse> updateMedia(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "profile",
      useFormData: true,
      formData: FormData.fromMap(req),
    );

    return response;
  }


  @override
  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "profile/updateProfilePic",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateProfile(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "profile/updateProfile",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getRaffle() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getAds() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      reqParams: {
        "media_type": "APP_BANNER",
        "page": 1,
        "page_size": 10,
      },
      endpoint: "media/list",
    );

    return response;
  }


  @override
  Future<ApiResponse> getDrawEvents() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/events/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getRaffleWinners() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/winners/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getSoldOutRaffle() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/soldout/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getRaffleResult() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/result/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> getFeaturedRaffle() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/featured/list",
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
      endpoint: "orders",
    );

    return response;
  }

  // @override
  // Future<ApiResponse> getOrdersStatus(Map<String, dynamic> req) async {
  //   print('order values are: ${req}');
  //   ApiResponse response = await api.call(
  //     method: HttpMethod.get,
  //     endpoint: "orders/status/",
  //     reqParams: req,
  //   );
  //
  //   return response;
  // }

  @override
  Future<ApiResponse> getOrdersStatus(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "validate",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> raffleList() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "raffle/tickets/list",
    );

    return response;
  }

  @override
  Future<ApiResponse> cartList() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "cart",
    );

    return response;
  }

  @override
  Future<ApiResponse> rating(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "orders/review",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> clearCart() async {
    ApiResponse response = await api.call(
      method: HttpMethod.delete,
      endpoint: "cart/clear",
    );

    return response;
  }

  @override
  Future<ApiResponse> addToCart(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "cart",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> deleteFromCart(String productId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.delete,
      endpoint: "cart/remove/$productId",
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
  Future<ApiResponse> getTransactions({int page = 1, int pageSize = 10}) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "payments/list",
      reqParams: {
        "page": page,
        "page_size": pageSize,
      },
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

  Future<ApiResponse> supportCountries() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "system/country_list",
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
      Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/update-user-password",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getCategories() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "categories",
    );
    return response;
  }

  @override
  Future<ApiResponse> getNotifications() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "notifications/list",
    );

    return response;
  }

  //repo for mark as read on notification
  @override
  Future<ApiResponse> markNotificationAsRead() async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "notifications/read",
    );

    return response;
  }

  @override
  Future<ApiResponse> saveShipping(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "profile/address",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> calculateOrder(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "orders/calculate",
      reqBody: req,
    );

    return response;
  }



  @override
  Future<ApiResponse> getAddresses() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "profile/addresses",
    );

    return response;
  }

  @override
  Future<ApiResponse> getDeliveryZones() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "admin/delivery/zones",
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
  Future<ApiResponse> deleteDefaultShipping(String productId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/delete_shipping/$productId",
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

  @override
  Future<ApiResponse> getExchangeRate({
    required double amount,
    required String destinationCurrency,
    required String sourceCurrency,
  }) async {
    String endpoint = '/transfers/rates';
    Map<String, dynamic> reqParams = {
      'amount': amount.toString(),
      'destination_currency': destinationCurrency,
      'source_currency': sourceCurrency,
    };
    return await api.call(
      method: HttpMethod.get,
      endpoint: endpoint,
      reqParams: reqParams,
      // protected: true, // This flag is used to decide if Authorization header should be included
    );
  }

}
