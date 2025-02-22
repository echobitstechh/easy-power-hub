
import 'package:afriprize/app/app.dialogs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../state.dart';
import '../../utils/dialog_utils.dart';
import '../data/repositories/repository.dart';
import '../utils/local_store_dir.dart';
import '../utils/local_stotage.dart';
import 'api_response.dart';
import 'api_service.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


final nav = locator<NavigationService>();

final logInterceptor = PrettyDioLogger(
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
bool isDialogBeingDisplayed = false;

final requestInterceptors = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  },
  onResponse: (Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  },
  onError: (DioError dioError, ErrorInterceptorHandler handler) async {

    // Future<DialogResponse?> showDialog(String title, String? description) async {
    //   if (!isDialogBeingDisplayed) {
    //     isDialogBeingDisplayed = true;
    //      DialogResponse? res = await locator<DialogService>().showCustomDialog(
    //       variant: DialogType.infoAlert,
    //       title: title,
    //       description: description,
    //     );
    //     isDialogBeingDisplayed = false;
    //     return res;
    //   }
    //   return null;
    // }

    if (dioError.type == DioErrorType.connectTimeout) {
      await showDialog("Connection Timed Out", null, isDialogBeingDisplayed);
    }
    else if (dioError.type == DioErrorType.other) {
      await showDialog("Network is unreachable", null, isDialogBeingDisplayed);
    }
    else if (dioError.type == DioErrorType.receiveTimeout) {
      await showDialog("Receive Timed Out", null, isDialogBeingDisplayed);
    }
    else if (dioError.response?.statusCode == 401 && !dioError.requestOptions.path.startsWith('auth')) {
      print('value of path is ${dioError.requestOptions.path}');
      if (refreshTokenRetryCount >= maxRetryCount) {
        // Reset counter and redirect user to login
        refreshTokenRetryCount = 0;
        ApiResponse res = await repo.logOut();
        if (res.statusCode == 200) {
          return locator<NavigationService>().clearStackAndShow(Routes.authView);
        }
      }
      refreshTokenRetryCount++;
      String? refreshToken = await locator<LocalStorage>().fetch(LocalStorageDir.authRefreshToken);

      if (refreshToken != null) {
        bool refreshTokenResult = await refreshAccessToken();

        if (refreshTokenResult) {
          refreshTokenRetryCount = 0;
          String newAccessToken = await locator<LocalStorage>().fetch(LocalStorageDir.authToken);
          final opts = Options(
            method: dioError.requestOptions.method,
            headers: {...dioError.requestOptions.headers,
              'Authorization': 'Bearer $newAccessToken',},
          );
          apiService.dio.request(
            dioError.requestOptions.path,
            options: opts,
            data: dioError.requestOptions.data,
            queryParameters: dioError.requestOptions.queryParameters,
          ).then(
                (r) => handler.resolve(r),
            onError: (e) => handler.reject(e),
          );
        } else {
          final res = await locator<DialogService>().showCustomDialog(
              variant: DialogType.infoAlert,
              title: "You are not logged in",
              description: "Login to continue");
          if (res!.confirmed) {
            userLoggedIn.value = false;
            await locator<LocalStorage>().delete(LocalStorageDir.authToken);
            await locator<LocalStorage>().delete(LocalStorageDir.authUser);
            await locator<LocalStorage>().delete(LocalStorageDir.cart);
            await locator<LocalStorage>().delete(LocalStorageDir.authRefreshToken);
            return locator<NavigationService>().clearStackAndShow(Routes.authView);
          }
        }
      }
      else {
        if (kDebugMode) {
          print('refresh token is null');
        }
        final res = await showDialogWithResponse("You are not logged in", "Login to continue", isDialogBeingDisplayed);
        if (res!.confirmed) {
          return locator<NavigationService>().clearStackAndShow(Routes.authView);
        }

      }
    }
    else if(dioError.response?.statusCode == 401 && dioError.requestOptions.path.startsWith('/auth')){
      if (kDebugMode) {
        print('incorrect credentials');
      }
      if(dioError.response != null && dioError.response!.statusMessage != null){
        await showDialog(dioError.response!.statusMessage!, null, isDialogBeingDisplayed);
      }

    }
    else{
      handler.next(dioError);
    }

  },
);

Future<bool> refreshAccessToken() async {
  String refreshToken = await locator<LocalStorage>().fetch(LocalStorageDir.authRefreshToken);

    ApiResponse res = await repo.refresh({
      "refreshToken": refreshToken
    });

    if (res.statusCode == 200 && res.data["token"] != null) {
      String accessToken = res.data["token"];
      String refreshToken = res.data["refreshToken"];
      await locator<LocalStorage>().save(LocalStorageDir.authToken, accessToken);
      await locator<LocalStorage>().save(LocalStorageDir.authRefreshToken, refreshToken);
      print('refresh successful');
      return true; // Refresh successful
    } else {
      print('refresh conditions aint true');
      return false; // Refresh failed
    }

}
