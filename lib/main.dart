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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: easyPhLightTheme,
      darkTheme: easyPhDarkTheme,
      themeMode: ThemeMode.system,
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