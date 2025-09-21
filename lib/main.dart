import 'package:easy_ph/state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_ph/app/app.bottomsheets.dart';
import 'package:easy_ph/app/app.dialogs.dart';
import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUiModes>(
      valueListenable:  uiMode,
      builder: (context, mode, _) => MaterialApp(
        initialRoute: Routes.startupView,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        themeMode: mode == AppUiModes.dark ? ThemeMode.dark : ThemeMode.light,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
      ),
    );
  }
}
