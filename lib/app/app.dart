import 'package:easy_ph/features/Profile/orders/order_view.dart';
import 'package:easy_ph/features/Profile/password/change_password_view.dart';
import 'package:easy_ph/features/Profile/profile_view.dart';
import 'package:easy_ph/features/Profile/shipping/shipping_address_view.dart';
import 'package:easy_ph/features/Profile/support/support_view.dart';
import 'package:easy_ph/features/auth/presentation/password_reset/password_reset_view.dart';
import 'package:easy_ph/features/cart/cart_view.dart';
import 'package:easy_ph/features/dashboard/presentation/product_details/product_card.dart';
import 'package:easy_ph/features/services/service_view.dart';
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
import '../features/Profile/onSuccess/success_view.dart';
import '../features/auth/presentation/auth_service.dart';
import '../features/auth/presentation/auth_viewmodel.dart';
import '../features/auth/presentation/widgets/login.dart';
import '../features/auth/presentation/widgets/otp_form.dart';
import '../features/auth/presentation/widgets/register.dart';
import '../features/home/presentation/home_view.dart';
import '../features/onboarding/presentation/onboarding_view.dart';
import '../ui/bottom_sheets/address_sheet/add_address_bottom_sheet.dart';
import '../ui/bottom_sheets/favourite/favourite_bottom_sheet.dart';
import '../ui/bottom_sheets/order_status/order_status_timeline.dart';
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
    MaterialRoute(page: CartView),
    MaterialRoute(page: ProductCard),
    MaterialRoute(page: EnterEmailView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: ServicesView),
    MaterialRoute(page: OrderList),
    MaterialRoute(page: ShippingAddressesPage),
    MaterialRoute(page: SupportView),
    MaterialRoute(page: ChangePasswordView),
    MaterialRoute(page: PaymentSuccessView),
    CustomRoute(
      page: Login,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 400,
    ),
    CustomRoute(
      page: Register,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 400,
    ),
    CustomRoute(
      page: OTPView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 400,
    ),
    // @stacked-route


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
    StackedBottomsheet(classType: OrderStatusTimelineSheet),
    StackedBottomsheet(classType: AddAddressBottomSheet),
    // StackedBottomsheet(classType: FavoritesBottomSheet),
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
