// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:easy_ph/core/data/models/cart_item.dart' as _i34;
import 'package:easy_ph/core/data/models/category.dart' as _i31;
import 'package:easy_ph/core/data/models/installment.dart' as _i36;
import 'package:easy_ph/core/data/models/product.dart' as _i32;
import 'package:easy_ph/core/data/models/savings.dart' as _i35;
import 'package:easy_ph/features/auth/presentation/password_reset/password_reset_view.dart'
    as _i9;
import 'package:easy_ph/features/auth/presentation/widgets/login.dart' as _i26;
import 'package:easy_ph/features/auth/presentation/widgets/otp_form.dart'
    as _i28;
import 'package:easy_ph/features/auth/presentation/widgets/register.dart'
    as _i27;
import 'package:easy_ph/features/cart/cart_view.dart' as _i6;
import 'package:easy_ph/features/cart/checkout/checkout_view.dart' as _i8;
import 'package:easy_ph/features/dashboard/presentation/dashboard_viewmodel.dart'
    as _i33;
import 'package:easy_ph/features/dashboard/presentation/product-search/search_view.dart'
    as _i15;
import 'package:easy_ph/features/dashboard/presentation/product_details/product_card.dart'
    as _i7;
import 'package:easy_ph/features/home/presentation/home_view.dart' as _i2;
import 'package:easy_ph/features/onboarding/presentation/onboarding_view.dart'
    as _i4;
import 'package:easy_ph/features/Profile/onSuccess/success_view.dart' as _i18;
import 'package:easy_ph/features/Profile/orders/order_view.dart' as _i12;
import 'package:easy_ph/features/Profile/password/change_password_view.dart'
    as _i17;
import 'package:easy_ph/features/Profile/profile_view.dart' as _i10;
import 'package:easy_ph/features/Profile/referral/referrals_view.dart' as _i16;
import 'package:easy_ph/features/Profile/shipping/shipping_address_view.dart'
    as _i13;
import 'package:easy_ph/features/Profile/support/support_view.dart' as _i14;
import 'package:easy_ph/features/services/service_view.dart' as _i11;
import 'package:easy_ph/features/shop/shop_view.dart' as _i5;
import 'package:easy_ph/features/startup/presentation/startup_view.dart' as _i3;
import 'package:easy_ph/features/wallet/installments/installment_details_view.dart'
    as _i25;
import 'package:easy_ph/features/wallet/installments/my_installments_view.dart'
    as _i24;
import 'package:easy_ph/features/wallet/savings/create_savings_view.dart'
    as _i22;
import 'package:easy_ph/features/wallet/savings/my_savings_view.dart' as _i20;
import 'package:easy_ph/features/wallet/savings/savings_details_view.dart'
    as _i21;
import 'package:easy_ph/features/wallet/savings/savings_success_view.dart'
    as _i23;
import 'package:easy_ph/features/wallet/wallet_view.dart' as _i19;
import 'package:flutter/foundation.dart' as _i30;
import 'package:flutter/material.dart' as _i29;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i37;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const onboardingView = '/onboarding-view';

  static const shopView = '/shop-view';

  static const cartView = '/cart-view';

  static const productCard = '/product-card';

  static const checkoutView = '/checkout-view';

  static const enterEmailView = '/enter-email-view';

  static const profileView = '/profile-view';

  static const servicesView = '/services-view';

  static const orderList = '/order-list';

  static const shippingAddressesPage = '/shipping-addresses-page';

  static const supportView = '/support-view';

  static const searchView = '/search-view';

  static const referralsView = '/referrals-view';

  static const changePasswordView = '/change-password-view';

  static const paymentSuccessView = '/payment-success-view';

  static const walletView = '/wallet-view';

  static const mySavingsView = '/my-savings-view';

  static const savingsDetailsView = '/savings-details-view';

  static const createSavingsView = '/create-savings-view';

  static const savingsSuccessView = '/savings-success-view';

  static const myInstallmentsView = '/my-installments-view';

  static const installmentDetailsView = '/installment-details-view';

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
    checkoutView,
    enterEmailView,
    profileView,
    servicesView,
    orderList,
    shippingAddressesPage,
    supportView,
    searchView,
    referralsView,
    changePasswordView,
    paymentSuccessView,
    walletView,
    mySavingsView,
    savingsDetailsView,
    createSavingsView,
    savingsSuccessView,
    myInstallmentsView,
    installmentDetailsView,
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
      Routes.checkoutView,
      page: _i8.CheckoutView,
    ),
    _i1.RouteDef(
      Routes.enterEmailView,
      page: _i9.EnterEmailView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i10.ProfileView,
    ),
    _i1.RouteDef(
      Routes.servicesView,
      page: _i11.ServicesView,
    ),
    _i1.RouteDef(
      Routes.orderList,
      page: _i12.OrderList,
    ),
    _i1.RouteDef(
      Routes.shippingAddressesPage,
      page: _i13.ShippingAddressesPage,
    ),
    _i1.RouteDef(
      Routes.supportView,
      page: _i14.SupportView,
    ),
    _i1.RouteDef(
      Routes.searchView,
      page: _i15.SearchView,
    ),
    _i1.RouteDef(
      Routes.referralsView,
      page: _i16.ReferralsView,
    ),
    _i1.RouteDef(
      Routes.changePasswordView,
      page: _i17.ChangePasswordView,
    ),
    _i1.RouteDef(
      Routes.paymentSuccessView,
      page: _i18.PaymentSuccessView,
    ),
    _i1.RouteDef(
      Routes.walletView,
      page: _i19.WalletView,
    ),
    _i1.RouteDef(
      Routes.mySavingsView,
      page: _i20.MySavingsView,
    ),
    _i1.RouteDef(
      Routes.savingsDetailsView,
      page: _i21.SavingsDetailsView,
    ),
    _i1.RouteDef(
      Routes.createSavingsView,
      page: _i22.CreateSavingsView,
    ),
    _i1.RouteDef(
      Routes.savingsSuccessView,
      page: _i23.SavingsSuccessView,
    ),
    _i1.RouteDef(
      Routes.myInstallmentsView,
      page: _i24.MyInstallmentsView,
    ),
    _i1.RouteDef(
      Routes.installmentDetailsView,
      page: _i25.InstallmentDetailsView,
    ),
    _i1.RouteDef(
      Routes.login,
      page: _i26.Login,
    ),
    _i1.RouteDef(
      Routes.register,
      page: _i27.Register,
    ),
    _i1.RouteDef(
      Routes.oTPView,
      page: _i28.OTPView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.OnboardingView: (data) {
      return _i29.PageRouteBuilder<dynamic>(
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
      return _i29.PageRouteBuilder<dynamic>(
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
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.CartView(),
        settings: data,
      );
    },
    _i7.ProductCard: (data) {
      final args = data.getArgs<ProductCardArguments>(nullOk: false);
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ProductCard(
            key: args.key,
            product: args.product,
            dashboardViewModel: args.dashboardViewModel),
        settings: data,
      );
    },
    _i8.CheckoutView: (data) {
      final args = data.getArgs<CheckoutViewArguments>(nullOk: false);
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.CheckoutView(
            key: args.key,
            cartSubtotal: args.cartSubtotal,
            cartDiscount: args.cartDiscount,
            cartItems: args.cartItems,
            calculatedFinalTotal: args.calculatedFinalTotal),
        settings: data,
      );
    },
    _i9.EnterEmailView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.EnterEmailView(),
        settings: data,
      );
    },
    _i10.ProfileView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.ProfileView(),
        settings: data,
      );
    },
    _i11.ServicesView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.ServicesView(),
        settings: data,
      );
    },
    _i12.OrderList: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.OrderList(),
        settings: data,
      );
    },
    _i13.ShippingAddressesPage: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.ShippingAddressesPage(),
        settings: data,
      );
    },
    _i14.SupportView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.SupportView(),
        settings: data,
      );
    },
    _i15.SearchView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.SearchView(),
        settings: data,
      );
    },
    _i16.ReferralsView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.ReferralsView(),
        settings: data,
      );
    },
    _i17.ChangePasswordView: (data) {
      final args = data.getArgs<ChangePasswordViewArguments>(
        orElse: () => const ChangePasswordViewArguments(),
      );
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.ChangePasswordView(
            isResetPassword: args.isResetPassword, key: args.key),
        settings: data,
      );
    },
    _i18.PaymentSuccessView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.PaymentSuccessView(),
        settings: data,
      );
    },
    _i19.WalletView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.WalletView(),
        settings: data,
      );
    },
    _i20.MySavingsView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.MySavingsView(),
        settings: data,
      );
    },
    _i21.SavingsDetailsView: (data) {
      final args = data.getArgs<SavingsDetailsViewArguments>(nullOk: false);
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i21.SavingsDetailsView(key: args.key, plan: args.plan),
        settings: data,
      );
    },
    _i22.CreateSavingsView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.CreateSavingsView(),
        settings: data,
      );
    },
    _i23.SavingsSuccessView: (data) {
      final args = data.getArgs<SavingsSuccessViewArguments>(
        orElse: () => const SavingsSuccessViewArguments(),
      );
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i23.SavingsSuccessView(key: args.key, message: args.message),
        settings: data,
      );
    },
    _i24.MyInstallmentsView: (data) {
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) => const _i24.MyInstallmentsView(),
        settings: data,
      );
    },
    _i25.InstallmentDetailsView: (data) {
      final args = data.getArgs<InstallmentDetailsViewArguments>(nullOk: false);
      return _i29.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i25.InstallmentDetailsView(key: args.key, plan: args.plan),
        settings: data,
      );
    },
    _i26.Login: (data) {
      return _i29.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i26.Login(),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i27.Register: (data) {
      return _i29.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i27.Register(),
        settings: data,
        transitionsBuilder:
            data.transition ?? _i1.TransitionsBuilders.slideRight,
        transitionDuration: const Duration(milliseconds: 400),
      );
    },
    _i28.OTPView: (data) {
      final args = data.getArgs<OTPViewArguments>(
        orElse: () => const OTPViewArguments(),
      );
      return _i29.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => _i28.OTPView(
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

  final _i30.Key? key;

  final _i31.Category? filter;

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

  final _i30.Key? key;

  final _i32.Product product;

  final _i33.DashboardViewModel dashboardViewModel;

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

class CheckoutViewArguments {
  const CheckoutViewArguments({
    this.key,
    required this.cartSubtotal,
    required this.cartDiscount,
    required this.cartItems,
    required this.calculatedFinalTotal,
  });

  final _i30.Key? key;

  final int cartSubtotal;

  final int cartDiscount;

  final List<_i34.CartItem> cartItems;

  final int calculatedFinalTotal;

  @override
  String toString() {
    return '{"key": "$key", "cartSubtotal": "$cartSubtotal", "cartDiscount": "$cartDiscount", "cartItems": "$cartItems", "calculatedFinalTotal": "$calculatedFinalTotal"}';
  }

  @override
  bool operator ==(covariant CheckoutViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.cartSubtotal == cartSubtotal &&
        other.cartDiscount == cartDiscount &&
        other.cartItems == cartItems &&
        other.calculatedFinalTotal == calculatedFinalTotal;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        cartSubtotal.hashCode ^
        cartDiscount.hashCode ^
        cartItems.hashCode ^
        calculatedFinalTotal.hashCode;
  }
}

class ChangePasswordViewArguments {
  const ChangePasswordViewArguments({
    this.isResetPassword = false,
    this.key,
  });

  final bool isResetPassword;

  final _i30.Key? key;

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

class SavingsDetailsViewArguments {
  const SavingsDetailsViewArguments({
    this.key,
    required this.plan,
  });

  final _i30.Key? key;

  final _i35.SavingsPlan plan;

  @override
  String toString() {
    return '{"key": "$key", "plan": "$plan"}';
  }

  @override
  bool operator ==(covariant SavingsDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.plan == plan;
  }

  @override
  int get hashCode {
    return key.hashCode ^ plan.hashCode;
  }
}

class SavingsSuccessViewArguments {
  const SavingsSuccessViewArguments({
    this.key,
    this.message = "Payment Successful!",
  });

  final _i30.Key? key;

  final String message;

  @override
  String toString() {
    return '{"key": "$key", "message": "$message"}';
  }

  @override
  bool operator ==(covariant SavingsSuccessViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.message == message;
  }

  @override
  int get hashCode {
    return key.hashCode ^ message.hashCode;
  }
}

class InstallmentDetailsViewArguments {
  const InstallmentDetailsViewArguments({
    this.key,
    required this.plan,
  });

  final _i30.Key? key;

  final _i36.InstallmentPlan plan;

  @override
  String toString() {
    return '{"key": "$key", "plan": "$plan"}';
  }

  @override
  bool operator ==(covariant InstallmentDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.plan == plan;
  }

  @override
  int get hashCode {
    return key.hashCode ^ plan.hashCode;
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

  final _i30.Key? key;

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

extension NavigatorStateExtension on _i37.NavigationService {
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
    _i30.Key? key,
    _i31.Category? filter,
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
    _i30.Key? key,
    required _i32.Product product,
    required _i33.DashboardViewModel dashboardViewModel,
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

  Future<dynamic> navigateToCheckoutView({
    _i30.Key? key,
    required int cartSubtotal,
    required int cartDiscount,
    required List<_i34.CartItem> cartItems,
    required int calculatedFinalTotal,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.checkoutView,
        arguments: CheckoutViewArguments(
            key: key,
            cartSubtotal: cartSubtotal,
            cartDiscount: cartDiscount,
            cartItems: cartItems,
            calculatedFinalTotal: calculatedFinalTotal),
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

  Future<dynamic> navigateToReferralsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.referralsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChangePasswordView({
    bool isResetPassword = false,
    _i30.Key? key,
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

  Future<dynamic> navigateToWalletView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.walletView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMySavingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.mySavingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSavingsDetailsView({
    _i30.Key? key,
    required _i35.SavingsPlan plan,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.savingsDetailsView,
        arguments: SavingsDetailsViewArguments(key: key, plan: plan),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCreateSavingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.createSavingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSavingsSuccessView({
    _i30.Key? key,
    String message = "Payment Successful!",
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.savingsSuccessView,
        arguments: SavingsSuccessViewArguments(key: key, message: message),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMyInstallmentsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.myInstallmentsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToInstallmentDetailsView({
    _i30.Key? key,
    required _i36.InstallmentPlan plan,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.installmentDetailsView,
        arguments: InstallmentDetailsViewArguments(key: key, plan: plan),
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
    _i30.Key? key,
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
    _i30.Key? key,
    _i31.Category? filter,
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
    _i30.Key? key,
    required _i32.Product product,
    required _i33.DashboardViewModel dashboardViewModel,
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

  Future<dynamic> replaceWithCheckoutView({
    _i30.Key? key,
    required int cartSubtotal,
    required int cartDiscount,
    required List<_i34.CartItem> cartItems,
    required int calculatedFinalTotal,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.checkoutView,
        arguments: CheckoutViewArguments(
            key: key,
            cartSubtotal: cartSubtotal,
            cartDiscount: cartDiscount,
            cartItems: cartItems,
            calculatedFinalTotal: calculatedFinalTotal),
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

  Future<dynamic> replaceWithReferralsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.referralsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChangePasswordView({
    bool isResetPassword = false,
    _i30.Key? key,
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

  Future<dynamic> replaceWithWalletView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.walletView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMySavingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.mySavingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSavingsDetailsView({
    _i30.Key? key,
    required _i35.SavingsPlan plan,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.savingsDetailsView,
        arguments: SavingsDetailsViewArguments(key: key, plan: plan),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCreateSavingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.createSavingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSavingsSuccessView({
    _i30.Key? key,
    String message = "Payment Successful!",
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.savingsSuccessView,
        arguments: SavingsSuccessViewArguments(key: key, message: message),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMyInstallmentsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.myInstallmentsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithInstallmentDetailsView({
    _i30.Key? key,
    required _i36.InstallmentPlan plan,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.installmentDetailsView,
        arguments: InstallmentDetailsViewArguments(key: key, plan: plan),
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
    _i30.Key? key,
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
