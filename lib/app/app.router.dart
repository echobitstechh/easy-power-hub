// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:easyph/core/data/models/order_info.dart' as _i22;
import 'package:easyph/core/data/models/order_item.dart' as _i26;
import 'package:easyph/core/data/models/product.dart' as _i24;
import 'package:easyph/core/data/models/profile.dart' as _i25;
import 'package:easyph/ui/components/payment_success_page.dart';
import 'package:easyph/ui/views/auth/auth_view.dart' as _i5;
import 'package:easyph/ui/views/auth/register.dart';
import 'package:easyph/ui/views/cart/add_shipping.dart';
import 'package:easyph/ui/views/cart/cart_view.dart' as _i8;
import 'package:easyph/ui/views/cart/add_shipping.dart' as _i13;
import 'package:easyph/ui/views/cart/raffle_reciept.dart' as _i13;
import 'package:easyph/ui/views/change_password/change_password_view.dart'
    as _i17;
import 'package:easyph/ui/views/dashboard/dashboard_view.dart' as _i6;
import 'package:easyph/ui/views/dashboard/raffle_detail.dart' as _i12;
import 'package:easyph/ui/views/delete_account/delete_account_view.dart'
    as _i19;
import 'package:easyph/ui/views/draws/draws_view.dart' as _i7;
import 'package:easyph/ui/views/enter_email/enter_email_view.dart' as _i18;
import 'package:easyph/ui/views/home/home_view.dart' as _i2;
import 'package:easyph/ui/views/service/service_view.dart' as _i9;
import 'package:easyph/ui/views/onboarding/onboarding_view.dart' as _i31;
import 'package:easyph/ui/views/otp/otp_view.dart' as _i16;
import 'package:easyph/ui/views/profile/profile_view.dart' as _i10;
import 'package:easyph/ui/views/profile/track.dart' as _i15;
import 'package:easyph/ui/views/profile/wallet.dart' as _i14;
import 'package:easyph/ui/views/startup/startup_view.dart' as _i3;
import 'package:easyph/ui/views/withdraw/withdraw_view.dart' as _i20;
import 'package:flutter/foundation.dart' as _i23;
import 'package:flutter/material.dart' as _i21;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i27;
import '../core/data/models/cart_item.dart';
import '../core/data/models/raffle_ticket.dart';
import '../ui/views/auth/auth_view.dart';
import '../ui/views/profile/order_list.dart';
import '../ui/views/profile/shipping_addresses_page.dart' as _i28;
import '../ui/views/service/projectDetailsPage.dart' as _i21;
import '../ui/views/service/projectDetailsPage.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const onboardingView2 = '/onboarding-view2';

  static const authView = '/auth-view';

  static const shippingView = '/shipping-view';

  static const dashboardView = '/dashboard-view';

  static const shopDashboardView = '/shop-dashboard-view';

  static const ticketView = '/ticket-view';

  static const orderView = '/order-view';

  static const drawsView = '/draws-view';

  static const cartView = '/cart-view';

  static const shopCartView = '/shop-cart-view';

  static const ServicesView = '/notification-view';

  static const profileView = '/profile-view';

  static const checkout = '/Checkout';

  static const productDetail = '/product-detail';

  static const shopDetail = '/shop-detail';

  static const receipt = '/Receipt';

  static const wallet = '/Wallet';

  static const track = '/Track';

  static const otpView = '/otp-view';

  static const changePasswordView = '/change-password-view';

  static const enterEmailView = '/enter-email-view';

  static const deleteAccountView = '/delete-account-view';

  static const withdrawView = '/withdraw-view';

  static const registerView = '/register-view';

  static const successView = '/success-view';
  
  static const detailsView = '/projectDetailsPage';

  static const all = <String>{
    homeView,
    startupView,
    onboardingView2,
    authView,
    dashboardView,
    shopDashboardView,
    ticketView,
    drawsView,
    cartView,
    shopCartView,
    ServicesView,
    profileView,
    checkout,
    productDetail,
    shopDetail,
    receipt,
    wallet,
    track,
    otpView,
    changePasswordView,
    enterEmailView,
    deleteAccountView,
    withdrawView,
    registerView,
    successView,
    shippingView,
    detailsView,
    orderView
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.ticketView,
      page: _i28.ShippingAddressesPage,
    ),
    _i1.RouteDef(
      Routes.orderView,
      page: OrderList,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.onboardingView2,
      page: _i31.OnboardingView,
    ),
    _i1.RouteDef(
      Routes.authView,
      page: _i5.AuthView,
    ),
    _i1.RouteDef(
      Routes.dashboardView,
      page: _i6.DashboardView,
    ),
    _i1.RouteDef(
      Routes.drawsView,
      page: _i7.DrawsView,
    ),
    _i1.RouteDef(
      Routes.cartView,
      page: _i8.CartView,
    ),
    _i1.RouteDef(
      Routes.ServicesView,
      page: _i9.ServicesView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i10.ProfileView,
    ),
    _i1.RouteDef(
      Routes.productDetail,
      page: _i12.RaffleDetail,
    ),
    _i1.RouteDef(
      Routes.receipt,
      page: _i13.RaffleReceiptPage,
    ),
    _i1.RouteDef(
      Routes.wallet,
      page: _i14.Wallet,
    ),
    // _i1.RouteDef(
    //   Routes.track,
    //   page: _i15.Track,
    // ),
    _i1.RouteDef(
      Routes.otpView,
      page: _i16.OtpView,
    ),
    _i1.RouteDef(
      Routes.changePasswordView,
      page: _i17.ChangePasswordView,
    ),
    _i1.RouteDef(
      Routes.enterEmailView,
      page: _i18.EnterEmailView,
    ),
    _i1.RouteDef(
      Routes.deleteAccountView,
      page: _i19.DeleteAccountView,
    ),
    _i1.RouteDef(
      Routes.withdrawView,
      page: _i20.WithdrawView,
    ),
    _i1.RouteDef(
      Routes.registerView,
      page: Register,
    ),
    _i1.RouteDef(
      Routes.successView,
      page: PaymentSuccessPage,
    ),
    _i1.RouteDef(
      Routes.shippingView,
      page: AddShipping,
    ),

    _i1.RouteDef(
      Routes.detailsView,
      page: ProjectDetailsPage,
    ),

  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    // Register: (data) {
    //   final args = data.getArgs<bool>(nullOk: false);
    //   return _i21.MaterialPageRoute<dynamic>(
    //     builder: (context) =>  Register(updateIsLogin: args),
    //     settings: data,
    //   );
    // },
    _i28.ShippingAddressesPage: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i28.ShippingAddressesPage(),
        settings: data,
      );
    },
    OrderList: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const OrderList(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i31.OnboardingView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>  _i31.OnboardingView(),
        settings: data,
      );
    },
    _i5.AuthView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.AuthView(),
        settings: data,
      );
    },
    _i6.DashboardView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>  _i6.DashboardView(),
        settings: data,
      );
    },
    _i7.DrawsView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>  const _i7.DrawsView(),
        settings: data,
      );
    },
    _i8.CartView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.CartView(),
        settings: data,
      );
    },
    _i9.ServicesView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.ServicesView(),
        settings: data,
      );
    },
    _i10.ProfileView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.ProfileView(),
        settings: data,
      );
    },
    _i12.RaffleDetail: (data) {
      final args = data.getArgs<RaffleDetailArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i12.RaffleDetail(raffle: args.raffle, key: args.key),
        settings: data,
      );
    },
    _i13.AddShipping: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.AddShipping(),
        settings: data,
      );
    },
    _i14.Wallet: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.Wallet(),
        settings: data,
      );
    },
    // _i15.Track: (data) {
    //   final args = data.getArgs<TrackArguments>(nullOk: false);
    //   return _i21.MaterialPageRoute<dynamic>(
    //     builder: (context) => _i15.Track(item: args.item, key: args.key),
    //     settings: data,
    //   );
    // },
    _i16.OtpView: (data) {
      final args = data.getArgs<OtpViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.OtpView(email: args.email, key: args.key),
        settings: data,
      );
    },
    _i17.ChangePasswordView: (data) {
      final args = data.getArgs<ChangePasswordViewArguments>(
        orElse: () => const ChangePasswordViewArguments(),
      );
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.ChangePasswordView(
            isResetPassword: args.isResetPassword, key: args.key),
        settings: data,
      );
    },
    _i18.EnterEmailView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.EnterEmailView(),
        settings: data,
      );
    },
    _i19.DeleteAccountView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.DeleteAccountView(),
        settings: data,
      );
    },
    _i20.WithdrawView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.WithdrawView(),
        settings: data,
      );
    },
    _i13.RaffleReceiptPage: (data) {
      final args = data.getArgs<RaffleReceiptArguments>(
        orElse: () => const RaffleReceiptArguments(carts: [], amount: 0),
      );
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.RaffleReceiptPage(carts: args.carts, totalAmount: args.amount, key: args.key),
        settings: data,
      );
    },


    
  };

  @override
  List<_i1.RouteDef> get routes => _routes;
  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class CheckoutArguments {
  const CheckoutArguments({
    required this.infoList,
    this.key,
  });

  final List<_i22.OrderInfo> infoList;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"infoList": "$infoList", "key": "$key"}';
  }

  @override
  bool operator ==(covariant CheckoutArguments other) {
    if (identical(this, other)) return true;
    return other.infoList == infoList && other.key == key;
  }

  @override
  int get hashCode {
    return infoList.hashCode ^ key.hashCode;
  }
}

// class ProductDetailArguments {
//   const ProductDetailArguments({
//     required this.product,
//     this.key,
//   });
//
//   final _i24.Product product;
//
//   final _i23.Key? key;
//
//   @override
//   String toString() {
//     return '{"product": "$product", "key": "$key"}';
//   }
//
//   @override
//   bool operator ==(covariant ProductDetailArguments other) {
//     if (identical(this, other)) return true;
//     return other.product == product && other.key == key;
//   }
//
//   @override
//   int get hashCode {
//     return product.hashCode ^ key.hashCode;
//   }
// }

class RaffleDetailArguments {
  const RaffleDetailArguments({
    required this.raffle,
    this.key,
  });

  final _i24.Raffle raffle;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"product": "$raffle", "key": "$key"}';
  }

  @override
  bool operator ==(covariant RaffleDetailArguments other) {
    if (identical(this, other)) return true;
    return other.raffle == raffle && other.key == key;
  }

  @override
  int get hashCode {
    return raffle.hashCode ^ key.hashCode;
  }
}

class ReceiptArguments {
  const ReceiptArguments({
    // required this.cart,
    required this.raffle,
    this.key,
  });

  // final List<CartItem> cart;
  final List<RaffleTicket> raffle;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"raffle": "$raffle", "key": "$key"}';
  }

  @override
  bool operator ==(covariant ReceiptArguments other) {
    if (identical(this, other)) return true;
    return
        other.raffle == raffle &&
        other.key == key;
  }

  @override
  int get hashCode {
    return  raffle.hashCode ^ key.hashCode;
  }
}

class WalletArguments {
  const WalletArguments({
    this.key,
  });


  final _i23.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant WalletArguments other) {
    if (identical(this, other)) return true;
    return  other.key == key;
  }

  @override
  int get hashCode {
    return   key.hashCode;
  }
}

// class TrackArguments {
//   const TrackArguments({
//     required this.item,
//     this.key,
//   });
//
//   final _i26.OrderItem item;
//
//   final _i23.Key? key;
//
//   @override
//   String toString() {
//     return '{"item": "$item", "key": "$key"}';
//   }
//
//   @override
//   bool operator ==(covariant TrackArguments other) {
//     if (identical(this, other)) return true;
//     return other.item == item && other.key == key;
//   }
//
//   @override
//   int get hashCode {
//     return item.hashCode ^ key.hashCode;
//   }
// }

class OtpViewArguments {
  const OtpViewArguments({
    required this.email,
    this.key,
  });

  final String email;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"email": "$email", "key": "$key"}';
  }

  @override
  bool operator ==(covariant OtpViewArguments other) {
    if (identical(this, other)) return true;
    return other.email == email && other.key == key;
  }

  @override
  int get hashCode {
    return email.hashCode ^ key.hashCode;
  }
}

class ChangePasswordViewArguments {
  const ChangePasswordViewArguments({
    this.isResetPassword = false,
    this.key,
  });

  final bool isResetPassword;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"isResetPassword": "$isResetPassword", "key": "$key"}';
  }

  @override
  bool operator ==(covariant ChangePasswordViewArguments other) {
    if (identical(this, other)) return true;
    return other.isResetPassword == isResetPassword && other.key == key;
  }

  @override
  int get hashCode {
    return isResetPassword.hashCode ^ key.hashCode;
  }
}

class RaffleReceiptArguments {
  const RaffleReceiptArguments({
    required this.carts,
    required this.amount,
    this.key,
  });

  final List<CartItem> carts;

  final int amount;

  final _i23.Key? key;

  @override
  String toString() {
    return '{ "carts": "$carts", "amount": "$amount", "key": "$key"}';
  }

  @override
  bool operator ==(covariant RaffleReceiptArguments other) {
    if (identical(this, other)) return true;
    return  other.carts == carts && other.amount == amount && other.key == key;
  }

  @override
  int get hashCode {
    return carts.hashCode ^ amount.hashCode ^ key.hashCode;
  }
}

extension NavigatorStateExtension on _i27.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }


  Future<dynamic> navigateToOnboardingView2([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.onboardingView2,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  // Future<dynamic> navigateToAuthView([
  //   int? routerId,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  //   Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
  //       transition,
  // ]) async {
  //   return navigateTo<dynamic>(Routes.authView,
  //       id: routerId,
  //       preventDuplicates: preventDuplicates,
  //       parameters: parameters,
  //       transition: transition);
  // }

  Future<dynamic> navigateToAuthView({
    required PresentPage initialPage,
    Map<String, String>? parameters,
    int? routerId,
    bool preventDuplicates = true,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.authView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      arguments: initialPage, // Pass the initial page as argument
      parameters: parameters, // Pass additional parameters
      transition: transition,
    );
  }

  Future<dynamic> navigateToAddShippingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.shippingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShopDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.shopDashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDrawsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.drawsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCartView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.cartView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShopCartView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.shopCartView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNotificationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.ServicesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCheckout({
    required List<_i22.OrderInfo> infoList,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.checkout,
        arguments: CheckoutArguments(infoList: infoList, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRaffleDetail({
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.productDetail,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShopDetail({
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {

    return navigateTo<dynamic>(Routes.shopDetail,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToReceipt({
    required List<RaffleTicket> raffle,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.receipt,
        arguments:
            ReceiptArguments(raffle: raffle, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWallet({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.wallet,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  // Future<dynamic> navigateToTrack({
  //   required _i26.OrderItem item,
  //   _i23.Key? key,
  //   int? routerId,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  //   Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
  //       transition,
  // }) async {
  //   return navigateTo<dynamic>(Routes.track,
  //       arguments: TrackArguments(item: item, key: key),
  //       id: routerId,
  //       preventDuplicates: preventDuplicates,
  //       parameters: parameters,
  //       transition: transition);
  // }

  Future<dynamic> navigateToOtpView({
    required String email,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.otpView,
        arguments: OtpViewArguments(email: email, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChangePasswordView({
    bool isResetPassword = false,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.changePasswordView,
        arguments: ChangePasswordViewArguments(
            isResetPassword: isResetPassword, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEnterEmailView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.enterEmailView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDeleteAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.deleteAccountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWithdrawView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.withdrawView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }


  Future<dynamic> replaceWithOnboardingView2([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.onboardingView2,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAuthView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.authView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithShopDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.shopDashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDrawsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.drawsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCartView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.cartView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNotificationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.ServicesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCheckout({
    required List<_i22.OrderInfo> infoList,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.checkout,
        arguments: CheckoutArguments(infoList: infoList, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProductDetail({

    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.productDetail,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithShopDetail({
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(Routes.shopDetail,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithReceipt({
    required List<RaffleTicket> raffle,

    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.receipt,
        arguments:
            ReceiptArguments(raffle: raffle, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWallet({
    required _i25.Wallet wallet,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.wallet,
        arguments: WalletArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  // Future<dynamic> replaceWithTrack({
  //   required _i26.OrderItem item,
  //   _i23.Key? key,
  //   int? routerId,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  //   Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
  //       transition,
  // }) async {
  //   return replaceWith<dynamic>(Routes.track,
  //       arguments: TrackArguments(item: item, key: key),
  //       id: routerId,
  //       preventDuplicates: preventDuplicates,
  //       parameters: parameters,
  //       transition: transition);
  // }

  Future<dynamic> replaceWithOtpView({
    required String email,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.otpView,
        arguments: OtpViewArguments(email: email, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChangePasswordView({
    bool isResetPassword = false,
    _i23.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.changePasswordView,
        arguments: ChangePasswordViewArguments(
            isResetPassword: isResetPassword, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEnterEmailView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.enterEmailView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDeleteAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.deleteAccountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWithdrawView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.withdrawView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
