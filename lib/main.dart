import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';
import 'app/dev_utils.dart';
import 'app/errorHandler.dart';
import 'firebase_options.dart';
import 'core/utils/paystack_util.dart';
import 'core/utils/local_store_dir.dart';
import 'core/utils/local_stotage.dart';
import 'utils/money_util.dart';
import 'state.dart';
import 'app/app.locator.dart';
import 'app/app.dialogs.dart';
import 'app/app.bottomsheets.dart';
import 'app/app.router.dart';
import 'ui/common/app_colors.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ComprehensiveErrorHandler.initialize();
  await DeepLinkHandler.initialize();
  runZonedGuarded(_runApp, ComprehensiveErrorHandler.handleZonedError);
}

Future<void> _runApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  PaystackUtil.initialize(MoneyUtils().payStackPublicKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FirebaseCrashlytics.instance.setCustomKey('app_lifecycle_state', state.toString());

    // Resume deep link listening when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      DeepLinkHandler.resumeListening();
    }
  }

  void _initializeApp() {
    _initializeUIState();
    _setupUpdatePrompt();
  }

  Future<void> _initializeUIState() async {
    try {
      final savedMode = await locator<LocalStorage>().fetch(LocalStorageDir.uiMode);
      if (savedMode == "light") uiMode.value = AppUiModes.light;
      if (savedMode == "dark") uiMode.value = AppUiModes.dark;

      await FirebaseCrashlytics.instance.setCustomKey('ui_mode', savedMode ?? 'default');
    } catch (error) {
      // Silent error handling
    }
  }

  void _setupUpdatePrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final availability = await getUpdateAvailability();
        if (availability is UpdateAvailable) {
          _showUpdateDialog();
        }
      } catch (error) {
        // Silent error handling
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Center(child: CircularProgressIndicator()),
            debugShowCheckedModeBanner: false,
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          FirebaseCrashlytics.instance.setUserIdentifier(snapshot.data!.uid);
        }

        return ValueListenableBuilder<AppUiModes>(
          valueListenable: uiMode,
          builder: (context, mode, _) => MaterialApp(
            title: 'Easyph',
            theme: _lightTheme(),
            darkTheme: _darkTheme(),
            themeMode: mode == AppUiModes.dark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: Routes.startupView,
            onGenerateRoute: StackedRouter().onGenerateRoute,
            navigatorKey: StackedService.navigatorKey,
            navigatorObservers: [StackedService.routeObserver],
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              ErrorWidget.builder = ComprehensiveErrorHandler.getErrorWidgetBuilder();
              return widget ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  ThemeData _lightTheme() => ThemeData.light(useMaterial3: true).copyWith(
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kcBlackColor,
      ),
      iconTheme: const IconThemeData(color: kcBlackColor),
      backgroundColor: kcWhiteColor,
      elevation: 0,
    ),
    primaryColor: kcBackgroundColor,
    focusColor: kcPrimaryColor,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: kcBlackColor),
  );

  ThemeData _darkTheme() => ThemeData.dark().copyWith(
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kcWhiteColor,
      ),
      iconTheme: const IconThemeData(color: kcWhiteColor),
      elevation: 0,
    ),
    brightness: Brightness.dark,
    primaryColor: kcBackgroundColor,
    focusColor: kcPrimaryColor,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: kcWhiteColor),
  );

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/update.svg', height: 40),
              const ListTile(
                title: Text(
                  'App Updates',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'A new version of Easyph is now available.\nDownload now to enjoy our latest features.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Update Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}