import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_links/app_links.dart';
import 'package:update_available/update_available.dart';

import 'firebase_options.dart';
import 'core/utils/paystack_util.dart';
import 'core/utils/config.dart';
import 'core/utils/local_store_dir.dart';
import 'core/utils/local_stotage.dart';
import 'utils/money_util.dart';
import 'state.dart';

import 'app/app.locator.dart';
import 'app/app.dialogs.dart';
import 'app/app.bottomsheets.dart';
import 'app/app.router.dart';
import 'ui/common/app_colors.dart';

final AppLinks _appLinks = AppLinks();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  PaystackUtil.initialize(MoneyUtils().payStackPublicKey);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    _initializeUIState();
    _setupUpdatePrompt();
    _handleInitialDeepLink();
    _listenToDeepLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App returned to foreground (e.g. after payment)
      _listenToDeepLinks();
    }
  }

  void _initializeUIState() async {
    final savedMode = await locator<LocalStorage>().fetch(LocalStorageDir.uiMode);
    if (savedMode == "light") uiMode.value = AppUiModes.light;
    if (savedMode == "dark") uiMode.value = AppUiModes.dark;
  }

  void _setupUpdatePrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final availability = await getUpdateAvailability();
      if (availability is UpdateAvailable) _showUpdateDialog();
    });
  }

  void _handleInitialDeepLink() async {
    final uri = await _appLinks.getInitialLink();
    if (uri != null) _navigateFromUri(uri);
  }

  void _listenToDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) _navigateFromUri(uri);
    });
  }

  void _navigateFromUri(Uri uri) {
    debugPrint('Deep link received: ${uri.toString()}');
    debugPrint('URI Scheme: ${uri.scheme}');
    debugPrint('URI Host: ${uri.host}');
    debugPrint('URI Path: ${uri.path}');
    debugPrint('Query Params: ${uri.queryParameters}');

    final host = uri.host.toLowerCase();

    if (host.contains("payment-success")) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        locator<NavigationService>().clearStackAndShow(Routes.paymentSuccessPage);
      });
    } else if (host.contains("payment-failed")) {
      locator<NavigationService>().clearStackAndShow(Routes.orderList);
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Center(child: CircularProgressIndicator()));
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
                title: Text('App Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
