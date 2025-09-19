

import '../../network/api_response.dart';

abstract class IRepository {
  Future<ApiResponse> login(Map<String, dynamic> req);

  Future<ApiResponse> googleSignIn(Map<String, dynamic> req);

  Future<ApiResponse> requestOtp(Map<String, dynamic> req);

  Future<ApiResponse> submitOtp(Map<String, dynamic> req);

  Future<ApiResponse> logOut();

  Future<ApiResponse> refresh(Map<String, dynamic> req);

  Future<ApiResponse> register(Map<String, dynamic> req);

  Future<ApiResponse> verify(Map<String, dynamic> req);

  Future<ApiResponse> sendOtp(Map<String, dynamic> req);

  Future<ApiResponse> initializePayment(Map<String, dynamic> req);

  Future<ApiResponse> getProducts({required int page, required int limit});

  Future<ApiResponse> getProductTags();

  Future<ApiResponse> getProductsByTag({required String tagId, int page = 1, int limit = 10});

  Future<ApiResponse> getReviews( String productId);


  Future<ApiResponse> getServices();

  Future<ApiResponse> getProfile();

  Future<ApiResponse> initTransaction(Map<String, dynamic> req);

  Future<ApiResponse> saveOrder(Map<String, dynamic> req);

  Future<ApiResponse> modifyCartItem(String productId, String action);

  Future<ApiResponse> verifyTransaction(String ref);

  Future<ApiResponse> payForOrder(Map<String, dynamic> req);

  Future<ApiResponse> updatePassword(Map<String, dynamic> req, String email);

  Future<ApiResponse> forgotPassword(Map<String, dynamic> req);

  Future<ApiResponse> newPassword(Map<String, dynamic> req);

  Future<ApiResponse> resetPassword(Map<String, dynamic> req);

  Future<ApiResponse> requestDelete(Map<String, dynamic> req);

  Future<ApiResponse> deleteAccount(Map<String, dynamic> req);

  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req);

  Future<ApiResponse> withdraw(Map<String, dynamic> req);

  Future<ApiResponse> getOrderList();

  Future<ApiResponse> getOrdersStatus(Map<String, dynamic> req);

  Future<ApiResponse> cartList();

  Future<ApiResponse> clearCart();

  Future<ApiResponse> addToCart(Map<String, dynamic> req);

  Future<ApiResponse>  rating(Map<String, dynamic> req);

  Future<ApiResponse> deleteFromCart(String raffleId);

  Future<ApiResponse> getTransactions();

  Future<ApiResponse> recommendedProducts(String productId);

  Future<ApiResponse> getNotifications();

  Future<ApiResponse> getAddresses();

  Future<ApiResponse> getDeliveryZones();

  Future<ApiResponse> getCategories();

  Future<ApiResponse> updateNotification(String eventId);

  Future<ApiResponse> saveShipping(Map<String, dynamic> req);

  Future<ApiResponse> calculateOrder(Map<String, dynamic> req);

  Future<ApiResponse> setDefaultShipping(Map<String, dynamic> req, String id);

  Future<ApiResponse> deleteDefaultShipping(String productId);

  Future<ApiResponse> reviewOrder(Map<String, dynamic> req);
}
