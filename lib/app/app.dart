import 'package:easy_ph/features/Profile/profile_view.dart';
import 'package:easy_ph/features/auth/presentation/password_reset/password_reset_view.dart';
import 'package:easy_ph/features/cart/cart_view.dart';
import 'package:easy_ph/features/dashboard/presentation/widgets/product_card.dart';
import 'package:easy_ph/features/shop/shop_view.dart';
import 'package:easy_ph/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:easy_ph/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:easy_ph/features/startup/presentation/startup_view.dart';
import 'package:easy_ph/ui/dialogs/info_alert/rating_dialog.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/data/repositories/repository.dart';
import '../core/network/api_service.dart';
import '../core/utils/local_stotage.dart';
import '../features/auth/presentation/auth_service.dart';
import '../features/auth/presentation/auth_view.dart';
import '../features/auth/presentation/auth_viewmodel.dart';
import '../features/home/presentation/home_view.dart';
import '../features/onboarding/presentation/onboarding_view.dart';
import '../ui/bottom_sheets/profile_screen_sheet.dart';
import '../ui/dialogs/info_alert/phone_input_dialog.dart';
// @stacked-import

@StackedApp(
  logger: StackedLogger(),
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    CustomRoute(
      page: OnboardingView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 400,
    ),
    CustomRoute(
      page: ShopView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 400,
    ),
    MaterialRoute(page: AuthView),
    MaterialRoute(page: CartView),
    MaterialRoute(page: ProductCard),
    MaterialRoute(page: EnterEmailView),
    MaterialRoute(page: ProfileView)


    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: LocalStorage),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: ApiService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: Repository),
    LazySingleton(classType: AuthViewModel),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: ProfileScreenSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: RatingDialog),
    StackedDialog(classType: PhoneInputDialog),
    // @stacked-dialog
  ],

)
class App {}
