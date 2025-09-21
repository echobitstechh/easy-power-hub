// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:easy_ph/core/data/models/category.dart' as _i12;
import 'package:easy_ph/core/data/models/product.dart' as _i13;
import 'package:easy_ph/features/auth/presentation/auth_view.dart' as _i6;
import 'package:easy_ph/features/auth/presentation/password_reset/password_reset_view.dart'
    as _i9;
import 'package:easy_ph/features/cart/cart_view.dart' as _i7;
import 'package:easy_ph/features/dashboard/presentation/widgets/product_card.dart'
    as _i8;
import 'package:easy_ph/features/home/presentation/home_view.dart' as _i2;
import 'package:easy_ph/features/onboarding/presentation/onboarding_view.dart'
    as _i4;
import 'package:easy_ph/features/Profile/profile_view.dart' as _i10;
import 'package:easy_ph/features/shop/shop_view.dart' as _i5;
import 'package:easy_ph/features/startup/presentation/startup_view.dart' as _i3;
import 'package:flutter/material.dart' as _i11;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i14;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const onboardingView = '/onboarding-view';

  static const shopView = '/shop-view';

  static const authView = '/auth-view';

  static const cartView = '/cart-view';

  static const productCard = '/product-card';

  static const enterEmailView = '/enter-email-view';

  static const profileView = '/profile-view';

  static const all = <String>{
    homeView,
    startupView,
    onboardingView,
    shopView,
    authView,
    cartView,
    productCard,
    enterEmailView,
    profileView,
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
      Routes.authView,
      page: _i6.AuthView,
    ),
    _i1.RouteDef(
      Routes.cartView,
      page: _i7.CartView,
    ),
    _i1.RouteDef(
      Routes.productCard,
      page: _i8.ProductCard,
    ),
    _i1.RouteDef(
      Routes.enterEmailView,
      page: _i9.EnterEmailView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i10.ProfileView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.OnboardingView: (data) {
      return _i11.PageRouteBuilder<dynamic>(
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
      return _i11.PageRouteBuilder<dynamic>(
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
    _i6.AuthView: (data) {
      final args = data.getArgs<AuthViewArguments>(
        orElse: () => const AuthViewArguments(),
      );
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.AuthView(
            key: args.key,
            initialPage: args.initialPage,
            parametersArg: args.parametersArg),
        settings: data,
      );
    },
    _i7.CartView: (data) {
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.CartView(),
        settings: data,
      );
    },
    _i8.ProductCard: (data) {
      final args = data.getArgs<ProductCardArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i8.ProductCard(key: args.key, product: args.product),
        settings: data,
      );
    },
    _i9.EnterEmailView: (data) {
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.EnterEmailView(),
        settings: data,
      );
    },
    _i10.ProfileView: (data) {
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.ProfileView(),
        settings: data,
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

  final _i11.Key? key;

  final _i12.Category? filter;

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

class AuthViewArguments {
  const AuthViewArguments({
    this.key,
    this.initialPage,
    this.parametersArg,
  });

  final _i11.Key? key;

  final _i6.PresentPage? initialPage;

  final Map<String, dynamic>? parametersArg;

  @override
  String toString() {
    return '{"key": "$key", "initialPage": "$initialPage", "parametersArg": "$parametersArg"}';
  }

  @override
  bool operator ==(covariant AuthViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.initialPage == initialPage &&
        other.parametersArg == parametersArg;
  }

  @override
  int get hashCode {
    return key.hashCode ^ initialPage.hashCode ^ parametersArg.hashCode;
  }
}

class ProductCardArguments {
  const ProductCardArguments({
    this.key,
    required this.product,
  });

  final _i11.Key? key;

  final _i13.Product product;

  @override
  String toString() {
    return '{"key": "$key", "product": "$product"}';
  }

  @override
  bool operator ==(covariant ProductCardArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.product == product;
  }

  @override
  int get hashCode {
    return key.hashCode ^ product.hashCode;
  }
}

extension NavigatorStateExtension on _i14.NavigationService {
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
    _i11.Key? key,
    _i12.Category? filter,
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

  Future<dynamic> navigateToAuthView({
    _i11.Key? key,
    _i6.PresentPage? initialPage,
    Map<String, dynamic>? parametersArg,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.authView,
        arguments: AuthViewArguments(
            key: key, initialPage: initialPage, parametersArg: parametersArg),
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
    _i11.Key? key,
    required _i13.Product product,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.productCard,
        arguments: ProductCardArguments(key: key, product: product),
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
    _i11.Key? key,
    _i12.Category? filter,
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

  Future<dynamic> replaceWithAuthView({
    _i11.Key? key,
    _i6.PresentPage? initialPage,
    Map<String, dynamic>? parametersArg,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.authView,
        arguments: AuthViewArguments(
            key: key, initialPage: initialPage, parametersArg: parametersArg),
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
    _i11.Key? key,
    required _i13.Product product,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.productCard,
        arguments: ProductCardArguments(key: key, product: product),
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
}
