import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_service.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:easyph/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:easyph/ui/views/home/home_view.dart';
import 'package:easyph/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easyph/ui/views/auth/auth_view.dart';
import 'package:easyph/ui/views/dashboard/dashboard_view.dart';
import 'package:easyph/ui/views/cart/cart_view.dart';
import 'package:easyph/ui/views/profile/profile_view.dart';

import '../ui/views/auth/authService.dart';
import '../ui/views/cart/payment_success_page.dart';
import '../ui/dialogs/info_alert/rating_dialog.dart';
import '../ui/views/onboarding/onboading_view3.dart';
import '../ui/views/profile/order_list.dart';
import '../ui/views/profile/wallet.dart';
import 'package:easyph/ui/views/otp/otp_view.dart';
import 'package:easyph/ui/views/change_password/change_password_view.dart';
import 'package:easyph/ui/views/enter_email/enter_email_view.dart';
import 'package:easyph/ui/views/delete_account/delete_account_view.dart';
import 'package:easyph/ui/views/withdraw/withdraw_view.dart';

import '../ui/views/service/service_view.dart';
// @stacked-import
/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

@StackedApp(
  logger: StackedLogger(),
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: AuthView),
    MaterialRoute(page: DashboardView),
    MaterialRoute(page: CartView),
    MaterialRoute(page: ServicesView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: Wallet),

    MaterialRoute(page: OtpView),
    MaterialRoute(page: ChangePasswordView),
    MaterialRoute(page: EnterEmailView),
    MaterialRoute(page: DeleteAccountView),
    MaterialRoute(page: WithdrawView),
    MaterialRoute(page: PaymentSuccessPage, path: '/paymentSuccess'),
    MaterialRoute(page: OnboardingView3),
    MaterialRoute(page: OrderList),

// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: ApiService),
    LazySingleton(classType: LocalStorage),
    LazySingleton(classType: Repository),
    LazySingleton(classType: AuthService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: RatingDialog),
    // @stacked-dialog
  ],
)
class App {}
