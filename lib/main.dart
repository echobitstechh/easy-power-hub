import 'package:easyph/core/utils/config.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/state.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easyph/app/app.bottomsheets.dart';
import 'package:easyph/app/app.dialogs.dart';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';
import 'package:workmanager/workmanager.dart';
// import 'app/flutter_paystack/lib/flutter_paystack.dart';
import 'core/utils/paystack_util.dart';
import 'firebase_options.dart';
import 'package:rxdart/rxdart.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  PaystackUtil.initialize(MoneyUtils().payStackPublicKey);
  // Initialize Paystack with your public key
  // final  paystackPlugin = PaystackPlugin();
  // await paystackPlugin.initialize(publicKey: AppConfig.paystackApiKeyTest);


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.instance.requestPermission();
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    fetchUiState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdates();
    });    // handleDeepLinks();
  }

  // void handleDeepLinks() async {
  //   // Listen for deep links
  //   uriLinkStream.listen((Uri? uri) {
  //     if (uri != null) {
  //       print("Deep Link Received: ${uri.toString()}");
  //       // Handle navigation in the app
  //     }
  //   });
  // }
  void fetchUiState() async {
    String? savedMode =
        await locator<LocalStorage>().fetch(LocalStorageDir.uiMode);
    if (savedMode != null) {
      switch (savedMode) {
        case "light":
          uiMode.value = AppUiModes.light;
          break;
        case "dark":
          uiMode.value = AppUiModes.dark;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        bool isAuthenticated = snapshot.hasData && snapshot.data != null;

        return ValueListenableBuilder<AppUiModes>(
          valueListenable: uiMode,
          builder: (context, value, child) => MaterialApp(
            title: 'Easyph',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(),
            themeMode: value == AppUiModes.dark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: Routes.startupView,
            onGenerateRoute: StackedRouter().onGenerateRoute,
            navigatorKey: StackedService.navigatorKey,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              StackedService.routeObserver,
            ],
          ),
        );
      },
    );
  }


  ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kcWhiteColor,
        ),
        iconTheme: const IconThemeData(color: kcWhiteColor),
        toolbarTextStyle: const TextStyle(color: kcWhiteColor),
        elevation: 0,
        // systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      brightness: Brightness.dark,
      primaryColor: kcBackgroundColor,
      focusColor: kcPrimaryColor,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: kcWhiteColor),
    );
  }

  ThemeData lightTheme() {
    return ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kcBlackColor,
        ),
        iconTheme: const IconThemeData(color: kcBlackColor),
        toolbarTextStyle: const TextStyle(color: kcBlackColor),
        backgroundColor: kcWhiteColor,
        elevation: 0,
        // systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      primaryColor: kcBackgroundColor,
      focusColor: kcPrimaryColor,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: kcBlackColor),
    );
  }

  void checkForUpdates() async {
    final availability = await getUpdateAvailability();
    if (availability is UpdateAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUpdateCard();
      });
    }
  }

  void showUpdateCard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/update.svg',
                  height: 10,
                ),
                const ListTile(
                  title: Text('App Updates', style: TextStyle(fontSize: 12,
                    fontFamily: "Panchang", fontWeight: FontWeight.bold,)),
                  subtitle: Text('A new version of Easyph is now available.'
                      ' download now to enjoy our lastest features.', style: TextStyle(fontSize: 8,
                    fontFamily: "Panchang",)),
                ),
                ButtonBar(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        // Add logic to navigate to the store or perform the update
                      },
                      child: const Text('Update Now'),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.pop(context); // Close the dialog
                    //   },
                    //   child: Text('Later'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
