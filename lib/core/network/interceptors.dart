
import 'package:dio/dio.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../state.dart';
import '../data/repositories/repository.dart';
import '../utils/custom_pretty_dio_logger.dart';
import '../utils/dialog_utils.dart';
import '../utils/local_store_dir.dart';
import '../utils/local_stotage.dart';
import 'api_response.dart';
import 'api_service.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


final nav = locator<NavigationService>();

final logInterceptor = CustomPrettyDioLogger(
  requestHeader: true,
  requestBody: true,
  responseBody: true,
  responseHeader: false,
  error: true,
  compact: true,
  maxWidth: 90,
);

int refreshTokenRetryCount = 0;
const int maxRetryCount = 3;
final repo = locator<Repository>();
final apiService = locator<ApiService>();

final requestInterceptors = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  },
  onResponse: (Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  },
  onError: (DioException dioError, ErrorInterceptorHandler handler) async {
    // Handle common Dio exceptions
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        locator<SnackbarService>().showSnackbar(message: "Connection timed out", duration: const Duration(seconds: 3));
        handler.next(dioError);
        return;
      case DioExceptionType.receiveTimeout:
        locator<SnackbarService>().showSnackbar(message: "Request timed out", duration: const Duration(seconds: 3));
        handler.next(dioError);
        return;
      case DioExceptionType.sendTimeout:
        locator<SnackbarService>().showSnackbar(message: "Upload timed out", duration: const Duration(seconds: 3));
        handler.next(dioError);
        return;
      case DioExceptionType.unknown:
        locator<SnackbarService>().showSnackbar(message: "Network is unreachable", duration: const Duration(seconds: 3));
        handler.next(dioError);
        return;
      default:
        break;
    }

    // Check if the endpoint is for login or password reset
    final isAuthEndpoint = dioError.requestOptions.path.contains("auth/login") ||
        dioError.requestOptions.path.contains("auth/refresh-token");


    // Handle 401 (unauthorized)
    if (dioError.response?.statusCode == 401) {

      if (isAuthEndpoint) {
        // Let the original error pass through so the login/signup view can handle it
        handler.next(dioError);
        return;
      }

      // Prevent infinite retry loops
      if (refreshTokenRetryCount >= maxRetryCount) {
        refreshTokenRetryCount = 0;
        await repo.logOut();
        return;
      }

      refreshTokenRetryCount++;
      final refreshToken =
      await locator<LocalStorage>().fetch(LocalStorageDir.authRefreshToken);

      if (refreshToken != null) {
        final refreshSuccess = await refreshAccessToken();

        if (refreshSuccess) {
          refreshTokenRetryCount = 0;
          final newAccessToken =
          await locator<LocalStorage>().fetch(LocalStorageDir.authToken);

          final opts = Options(
            method: dioError.requestOptions.method,
            headers: <String, dynamic>{
              ...dioError.requestOptions.headers,
              'Authorization': 'Bearer $newAccessToken',
            },
          );

          // retry failed request
          apiService.dio
              .request(
            dioError.requestOptions.path,
            options: opts,
            data: dioError.requestOptions.data,
            queryParameters: dioError.requestOptions.queryParameters,
          )
              .then((r) => handler.resolve(r), onError: (e) => handler.reject(e));

          return;
        } else {
          await showSessionExpiredDialog();
          return;
        }
      } else {
        await showSessionExpiredDialog();
        return;
      }
    }

    // Pass error down the chain if not handled
    handler.next(dioError);
  },
);


Future<bool> refreshAccessToken() async {

    ApiResponse res = await repo.refresh({ "userId": profile.value.id,
      "refreshToken": await locator<LocalStorage>().fetch(LocalStorageDir.authRefreshToken)});
    if (res.statusCode == 200 && res.data["token"] != null) {
      String accessToken = res.data["token"];
      String refreshToken = res.data["refreshToken"];
      await locator<LocalStorage>().save(LocalStorageDir.authToken, accessToken);
      await locator<LocalStorage>().save(LocalStorageDir.authRefreshToken, refreshToken);
      print('refresh successful');
      return true; // Refresh successful
    } else {
      print('refresh conditions aint true');
      print(res.data);
      return false; // Refresh failed
    }

}

void stopLoadingOnTimeout(BaseViewModel viewModel) {
  viewModel.setBusy(false);
  // if (viewModel is DashboardViewModel) {
  //   viewModel.isCreateVisitLoading = false;
  //   viewModel.notifyListeners();
  // }
}

