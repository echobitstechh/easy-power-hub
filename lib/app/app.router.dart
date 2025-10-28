// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:easy_ph/core/data/models/category.dart' as _i22;
import 'package:easy_ph/core/data/models/product.dart' as _i23;
import 'package:easy_ph/features/auth/presentation/password_reset/password_reset_view.dart'
    as _i8;
import 'package:easy_ph/features/auth/presentation/widgets/login.dart' as _i18;
import 'package:easy_ph/features/auth/presentation/widgets/otp_form.dart'
    as _i20;
import 'package:easy_ph/features/auth/presentation/widgets/register.dart'
    as _i19;
import 'package:easy_ph/features/cart/cart_view.dart' as _i6;
import 'package:easy_ph/features/dashboard/presentation/dashboard_viewmodel.dart'
    as _i24;
import 'package:easy_ph/features/dashboard/presentation/product-search/search_view.dart'
    as _i14;
import 'package:easy_ph/features/dashboard/presentation/product_details/product_card.dart'
    as _i7;
import 'package:easy_ph/features/home/presentation/home_view.dart' as _i2;
import 'package:easy_ph/features/onboarding/presentation/onboarding_view.dart'
    as _i4;
import 'package:easy_ph/features/Profile/onSuccess/success_view.dart' as _i17;
import 'package:easy_ph/features/Profile/orders/order_view.dart' as _i11;
import 'package:easy_ph/features/Profile/password/change_password_view.dart'
    as _i16;
import 'package:easy_ph/features/Profile/profile_view.dart' as _i9;
import 'package:easy_ph/features/Profile/shipping/shipping_address_view.dart'
    as _i12;
import 'package:easy_ph/features/Profile/support/support_view.dart' as _i13;
import 'package:easy_ph/features/services/service_view.dart' as _i10;
import 'package:easy_ph/features/services/widgets/ServiceSuccessView.dart'
    as _i15;
import 'package:easy_ph/features/shop/shop_view.dart' as _i5;
import 'package:easy_ph/features/startup/presentation/startup_view.dart' as _i3;
import 'package:flutter/material.dart' as _i21;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i25;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const onboardingView = '/onboarding-view';

  static const shopView = '/shop-view';

  static const cartView = '/cart-view';

  static const productCard = '/product-card';

  static const enterEmailView = '/enter-email-view';

  static const profileView = '/profile-view';

  static const servicesView = '/services-view';

  static const orderList = '/order-list';

  static const shippingAddressesPage = '/shipping-addresses-page';

  static const supportView = '/support-view';

  static const searchView = '/search-view';

  static const serviceSuccessView = '/service-success-view';

  static const changePasswordView = '/change-password-view';

  static const paymentSuccessView = '/payment-success-view';

  static const login = '/Login';

  static const register = '/Register';

  static const oTPView = '/o-tp-view';

  static const all = <String>{
    homeView,
    startupView,
    onboardingView,
    shopView,
    cartView,
    productCard,
    enterEmailView,
    profileView,
    servicesView,
    orderList,
    shippingAddressesPage,
    supportView,
    searchView,
    serviceSuccessView,
    changePasswordView,
    paymentSuccessView,
    login,
    register,
    oTPView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.onboardingView,
      page: _i4.OnboardingView,
    ),
    _i1.RouteDef(
      Routes.shopView,
      page: _i5.ShopView,
    ),
    _i1.RouteDef(
      Routes.cartView,
      page: _i6.CartView,
    ),
    _i1.RouteDef(
      Routes.productCard,
      page: _i7.ProductCard,
    ),
    _i1.RouteDef(
      Routes.enterEmailView,
      page: _i8.EnterEmailView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i9.ProfileView,
    ),
    _i1.RouteDef(
      Routes.servicesView,
      page: _i10.ServicesView,
    ),
    _i1.RouteDef(
      Routes.orderList,
      page: _i11.OrderList,
    ),
    _i1.RouteDef(
      Routes.shippingAddressesPage,
      page: _i12.ShippingAddressesPage,
    ),
    _i1.RouteDef(
      Routes.supportView,
      page: _i13.SupportView,
    ),
    _i1.RouteDef(
      Routes.searchView,
      page: _i14.SearchView,
    ),
    _i1.RouteDef(
      Routes.serviceSuccessView,
      page: _i15.ServiceSuccessView,
    ),
    _i1.RouteDef(
      Routes.changePasswordView,
      page: _i16.ChangePasswordView,
    ),
    _i1.RouteDef(
      Routes.paymentSuccessView,
      page: _i17.PaymentSuccessView,
    ),
    _i1.RouteDef(
      Routes.login,
      page: _i18.Login,
    ),
    _i1.RouteDef(
      Routes.register,
      page: _i19.Register,
    ),
    _i1.RouteDef(
      Routes.oTPView,
      page: _i20.OTPView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.OnboardingView: (data) {
      return _i21.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i4.OnboardingView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i5.ShopView: (data) {
      final args = data.getArgs<ShopViewArguments>(
        orElse: () => const ShopViewArguments(),
      );
      return _i21.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => _i5.ShopView(
            key: args.key,
            filter: args.filter,
            isSpecialCategory: args.isSpecialCategory),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i6.CartView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.CartView(),
        settings: data,
      );
    },
    _i7.ProductCard: (data) {
      final args = data.getArgs<ProductCardArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ProductCard(
            key: args.key,
            product: args.product,
            dashboardViewModel: args.dashboardViewModel),
        settings: data,
      );
    },
    _i8.EnterEmailView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.EnterEmailView(),
        settings: data,
      );
    },
    _i9.ProfileView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.ProfileView(),
        settings: data,
      );
    },
    _i10.ServicesView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.ServicesView(),
        settings: data,
      );
    },
    _i11.OrderList: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.OrderList(),
        settings: data,
      );
    },
    _i12.ShippingAddressesPage: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.ShippingAddressesPage(),
        settings: data,
      );
    },
    _i13.SupportView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.SupportView(),
        settings: data,
      );
    },
    _i14.SearchView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.SearchView(),
        settings: data,
      );
    },
    _i15.ServiceSuccessView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.ServiceSuccessView(),
        settings: data,
      );
    },
    _i16.ChangePasswordView: (data) {
      final args = data.getArgs<ChangePasswordViewArguments>(
        orElse: () => const ChangePasswordViewArguments(),
      );
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.ChangePasswordView(
            isResetPassword: args.isResetPassword, key: args.key),
        settings: data,
      );
    },
    _i17.PaymentSuccessView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.PaymentSuccessView(),
        settings: data,
      );
    },
    _i18.Login: (data) {
      return _i21.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i18.Login(),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i19.Register: (data) {
      return _i21.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i19.Register(),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i20.OTPView: (data) {
      final args = data.getArgs<OTPViewArguments>(
        orElse: () => const OTPViewArguments(),
      );
      return _i21.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => _i20.OTPView(
            key: args.key,
            isOtpRequested: args.isOtpRequested,
            userId: args.userId,
            verificationCode: args.verificationCode,
            phone: args.phone,
            email: args.email),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class ShopViewArguments {
  const ShopViewArguments({
    this.key,
    this.filter,
    this.isSpecialCategory = false,
  });

  final _i21.Key? key;

  final _i22.Category? filter;

  final bool isSpecialCategory;

  @override
  String toString() {
    return '{"key": "$key", "filter": "$filter", "isSpecialCategory": "$isSpecialCategory"}';
  }

  @override
  bool operator ==(covariant ShopViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.filter == filter &&
        other.isSpecialCategory == isSpecialCategory;
  }

  @override
  int get hashCode {
    return key.hashCode ^ filter.hashCode ^ isSpecialCategory.hashCode;
  }
}

class ProductCardArguments {
  const ProductCardArguments({
    this.key,
    required this.product,
    required this.dashboardViewModel,
  });

  final _i21.Key? key;

  final _i23.Product product;

  final _i24.DashboardViewModel dashboardViewModel;

  @override
  String toString() {
    return '{"key": "$key", "product": "$product", "dashboardViewModel": "$dashboardViewModel"}';
  }

  @override
  bool operator ==(covariant ProductCardArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.product == product &&
        other.dashboardViewModel == dashboardViewModel;
  }

  @override
  int get hashCode {
    return key.hashCode ^ product.hashCode ^ dashboardViewModel.hashCode;
  }
}

class ChangePasswordViewArguments {
  const ChangePasswordViewArguments({
    this.isResetPassword = false,
    this.key,
  });

  final bool isResetPassword;

  final _i21.Key? key;

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

class OTPViewArguments {
  const OTPViewArguments({
    this.key,
    this.isOtpRequested = false,
    this.userId,
    this.verificationCode,
    this.phone,
    this.email,
  });

  final _i21.Key? key;

  final bool isOtpRequested;

  final String? userId;

  final String? verificationCode;

  final String? phone;

  final String? email;

  @override
  String toString() {
    return '{"key": "$key", "isOtpRequested": "$isOtpRequested", "userId": "$userId", "verificationCode": "$verificationCode", "phone": "$phone", "email": "$email"}';
  }

  @override
  bool operator ==(covariant OTPViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.isOtpRequested == isOtpRequested &&
        other.userId == userId &&
        other.verificationCode == verificationCode &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        isOtpRequested.hashCode ^
        userId.hashCode ^
        verificationCode.hashCode ^
        phone.hashCode ^
        email.hashCode;
  }
}

extension NavigatorStateExtension on _i25.NavigationService {
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

  Future<dynamic> navigateToOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShopView({
    _i21.Key? key,
    _i22.Category? filter,
    bool isSpecialCategory = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.shopView,
        arguments: ShopViewArguments(
            key: key, filter: filter, isSpecialCategory: isSpecialCategory),
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

  Future<dynamic> navigateToProductCard({
    _i21.Key? key,
    required _i23.Product product,
    required _i24.DashboardViewModel dashboardViewModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.productCard,
        arguments: ProductCardArguments(
            key: key, product: product, dashboardViewModel: dashboardViewModel),
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

  Future<dynamic> navigateToServicesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.servicesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOrderList([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.orderList,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShippingAddressesPage([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.shippingAddressesPage,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSupportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.supportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.searchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToServiceSuccessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.serviceSuccessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChangePasswordView({
    bool isResetPassword = false,
    _i21.Key? key,
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

  Future<dynamic> navigateToPaymentSuccessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.paymentSuccessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLogin([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.login,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegister([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.register,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOTPView({
    _i21.Key? key,
    bool isOtpRequested = false,
    String? userId,
    String? verificationCode,
    String? phone,
    String? email,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.oTPView,
        arguments: OTPViewArguments(
            key: key,
            isOtpRequested: isOtpRequested,
            userId: userId,
            verificationCode: verificationCode,
            phone: phone,
            email: email),
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

  Future<dynamic> replaceWithOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithShopView({
    _i21.Key? key,
    _i22.Category? filter,
    bool isSpecialCategory = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.shopView,
        arguments: ShopViewArguments(
            key: key, filter: filter, isSpecialCategory: isSpecialCategory),
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

  Future<dynamic> replaceWithProductCard({
    _i21.Key? key,
    required _i23.Product product,
    required _i24.DashboardViewModel dashboardViewModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.productCard,
        arguments: ProductCardArguments(
            key: key, product: product, dashboardViewModel: dashboardViewModel),
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

  Future<dynamic> replaceWithServicesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.servicesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOrderList([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.orderList,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithShippingAddressesPage([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.shippingAddressesPage,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSupportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.supportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.searchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithServiceSuccessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.serviceSuccessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChangePasswordView({
    bool isResetPassword = false,
    _i21.Key? key,
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

  Future<dynamic> replaceWithPaymentSuccessView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.paymentSuccessView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLogin([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.login,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegister([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.register,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOTPView({
    _i21.Key? key,
    bool isOtpRequested = false,
    String? userId,
    String? verificationCode,
    String? phone,
    String? email,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.oTPView,
        arguments: OTPViewArguments(
            key: key,
            isOtpRequested: isOtpRequested,
            userId: userId,
            verificationCode: verificationCode,
            phone: phone,
            email: email),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
