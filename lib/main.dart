import 'package:easy_ph/core/services/theme_service.dart';
import 'package:easy_ph/state.dart';
import 'package:easy_ph/ui/common/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_ph/app/app.bottomsheets.dart';
import 'package:easy_ph/app/app.dialogs.dart';
import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:uni_links/uni_links.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  setupDeepLinkHandler();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeService = locator<ThemeService>();
  await themeService.init();

  runApp(const MainApp());
}

void setupDeepLinkHandler() {

  final _navigationService = locator<NavigationService>();

  getLinksStream().listen((String? uri) {
    if (uri != null) {
      if (uri == 'easyph://payment-success') {
        _navigationService.navigateTo(Routes.paymentSuccessView);
      }
    }
  }, onError: (err) {
    print('Failed to receive deep link: $err');
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final themeService = locator<ThemeService>();

  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: easyPhLightTheme,
      darkTheme: easyPhDarkTheme,
      themeMode: themeService.themeMode,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
