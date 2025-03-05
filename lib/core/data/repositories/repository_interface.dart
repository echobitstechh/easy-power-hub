import 'package:afriprize/core/network/api_response.dart';

abstract class IRepository {
  Future<ApiResponse> login(Map<String, dynamic> req);

  Future<ApiResponse> requestOtp(Map<String, dynamic> req);

  Future<ApiResponse> submitOtp(Map<String, dynamic> req);

  Future<ApiResponse> logOut();

  Future<ApiResponse> refresh(Map<String, dynamic> req);

  Future<ApiResponse> register(Map<String, dynamic> req);

  Future<ApiResponse> verify(Map<String, dynamic> req);

  Future<ApiResponse> sendOtp(Map<String, dynamic> req);

  Future<ApiResponse> getProducts();

  Future<ApiResponse> getRaffle();

  Future<ApiResponse> getAds();

  Future<ApiResponse> getDrawEvents();

  Future<ApiResponse> getRaffleWinners();

  Future<ApiResponse> getSoldOutRaffle();

  Future<ApiResponse> getRaffleResult();

  Future<ApiResponse> getServices();

  Future<ApiResponse> getProjectComments(String projectId);

  Future<ApiResponse> getProfile();

  Future<ApiResponse> initTransaction(Map<String, dynamic> req);

  Future<ApiResponse> donateToProject(Map<String, dynamic> req);

  Future<ApiResponse> saveOrder(Map<String, dynamic> req);

  Future<ApiResponse> modifyCartItem(String productId, String action);

  Future<ApiResponse> verifyTransaction(String ref);

  Future<ApiResponse> payForOrder(Map<String, dynamic> req);

  Future<ApiResponse> convertToNaira(String amount);

  Future<ApiResponse> updatePassword(Map<String, dynamic> req, String email);

  Future<ApiResponse> forgotPassword(Map<String, dynamic> req);

  Future<ApiResponse> newPassword(Map<String, dynamic> req);

  Future<ApiResponse> resetPassword(Map<String, dynamic> req);

  Future<ApiResponse> requestDelete(Map<String, dynamic> req);

  Future<ApiResponse> deleteAccount(Map<String, dynamic> req);

  Future<ApiResponse> makeComment(Map<String, dynamic> req);

  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req);

  Future<ApiResponse> updateMedia(Map<String, dynamic> req);

  Future<ApiResponse> getBanks();

  Future<ApiResponse> withdraw(Map<String, dynamic> req);

  Future<ApiResponse> getOrderList();

  Future<ApiResponse> getOrdersStatus(Map<String, dynamic> req);

  Future<ApiResponse> raffleList();

  Future<ApiResponse> cartList();

  Future<ApiResponse> clearCart();

  Future<ApiResponse> addToCart(Map<String, dynamic> req);

  Future<ApiResponse> deleteFromCart(String raffleId);

  Future<ApiResponse> verifyName(Map<String, dynamic> req);

  Future<ApiResponse> getTransactions();

  Future<ApiResponse> recommendedProducts(String productId);

  Future<ApiResponse> getResourceList();

  Future<ApiResponse> getNotifications();

  Future<ApiResponse> getAddresses();

  Future<ApiResponse> getCategories();

  Future<ApiResponse> updateNotification(String eventId);

  Future<ApiResponse> saveShipping(Map<String, dynamic> req);

  Future<ApiResponse> setDefaultShipping(Map<String, dynamic> req, String id);

  Future<ApiResponse> deleteDefaultShipping(String productId);

  Future<ApiResponse> reviewOrder(Map<String, dynamic> req);

  Future<ApiResponse> getExchangeRate({required double amount,
    required String destinationCurrency,
    required String sourceCurrency,
  });
}
