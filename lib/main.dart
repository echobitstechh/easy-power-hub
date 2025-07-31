import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_links/app_links.dart';
import 'package:update_available/update_available.dart';
import 'package:flutter/foundation.dart';
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

final AppLinks _appLinks = AppLinks();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ComprehensiveErrorHandler.initialize();

  developer.log(' Starting app with comprehensive error handling...', name: 'Main');

  runZonedGuarded(_runApp, _onZonedError);
}

Future<void> _runApp() async {
  await ComprehensiveErrorHandler.wrapWithErrorHandling(
    operationName: 'App Initialization',
    operation: () async {
      developer.log('Initializing Firebase...', name: 'Init');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      developer.log('Setting up Firebase Crashlytics...', name: 'Init');
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      developer.log('Setting up services...', name: 'Init');
      setupLocator();
      setupDialogUi();
      setupBottomSheetUi();

      developer.log('Initializing PayStack...', name: 'Init');
      PaystackUtil.initialize(MoneyUtils().payStackPublicKey);

      developer.log('All initialization complete, starting app...', name: 'Init');
      runApp(const MyApp());

      if (kDebugMode) {
        Timer(const Duration(seconds: 10), () {
          developer.log(' Starting error reporting tests...', name: 'Test');
          ComprehensiveErrorHandler.testAllErrorTypes();
        });
      }
    },
    customData: {'phase': 'app_initialization'},
  );
}

void _onZonedError(Object error, StackTrace stackTrace) async {
  developer.log('💥 ZONED ERROR CAUGHT: $error',
      name: 'ZonedError',
      error: error,
      stackTrace: stackTrace
  );

  await ComprehensiveErrorHandler.reportError(
    error: error,
    stackTrace: stackTrace,
    context: 'Uncaught error in runZonedGuarded',
    customData: {'error_type': 'zoned_error'},
    fatal: true,
  );
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
    developer.log('App lifecycle changed: $state', name: 'Lifecycle');
    FirebaseCrashlytics.instance.setCustomKey('app_lifecycle_state', state.toString());

    if (state == AppLifecycleState.resumed) {
      _listenToDeepLinks();
    }
  }

  void _initializeApp() {
    ComprehensiveErrorHandler.wrapWithErrorHandling(
      operationName: 'MyApp initialization',
      operation: () async {
        await _initializeUIState();
        _setupUpdatePrompt();
        await _handleInitialDeepLink();
        _listenToDeepLinks();
      },
      customData: {'component': 'MyApp'},
    );
  }

  Future<void> _initializeUIState() async {
    try {
      final savedMode = await locator<LocalStorage>().fetch(LocalStorageDir.uiMode);
      if (savedMode == "light") uiMode.value = AppUiModes.light;
      if (savedMode == "dark") uiMode.value = AppUiModes.dark;

      await FirebaseCrashlytics.instance.setCustomKey('ui_mode', savedMode ?? 'default');
      developer.log('🎨 UI mode set: ${savedMode ?? 'default'}', name: 'UI');
    } catch (error, stackTrace) {
      await ComprehensiveErrorHandler.reportError(
        error: error,
        stackTrace: stackTrace,
        context: 'Failed to initialize UI state',
        customData: {'operation': 'ui_state_init'},
      );
    }
  }

  void _setupUpdatePrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ComprehensiveErrorHandler.wrapWithErrorHandling(
        operationName: 'Update check',
        operation: () async {
          final availability = await getUpdateAvailability();
          if (availability is UpdateAvailable) {
            developer.log('Update available', name: 'Update');
            _showUpdateDialog();
          }
        },
        customData: {'operation': 'update_check'},
      );
    });
  }

  Future<void> _handleInitialDeepLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        developer.log('Initial deep link: ${uri.toString()}', name: 'DeepLink');
        _navigateFromUri(uri);
      }
    } catch (error, stackTrace) {
      await ComprehensiveErrorHandler.reportError(
        error: error,
        stackTrace: stackTrace,
        context: 'Failed to handle initial deep link',
        customData: {'operation': 'initial_deep_link'},
      );
    }
  }

  void _listenToDeepLinks() {
    try {
      _appLinks.uriLinkStream.listen(
            (uri) {
          developer.log('Deep link received: ${uri.toString()}', name: 'DeepLink');
          _navigateFromUri(uri);
        },
        onError: (error, stackTrace) {
          ComprehensiveErrorHandler.reportError(
            error: error,
            stackTrace: stackTrace ?? StackTrace.current,
            context: 'Deep link stream error',
            customData: {'operation': 'deep_link_stream'},
          );
        },
      );
    } catch (error, stackTrace) {
      ComprehensiveErrorHandler.reportError(
        error: error,
        stackTrace: stackTrace,
        context: 'Failed to setup deep link listener',
        customData: {'operation': 'deep_link_listener_setup'},
      );
    }
  }

  void _navigateFromUri(Uri uri) {
    ComprehensiveErrorHandler.wrapWithErrorHandling(
      operationName: 'Deep link navigation',
      operation: () async {
        final host = uri.host.toLowerCase();

        await FirebaseCrashlytics.instance.setCustomKey('last_deep_link_host', host);
        await FirebaseCrashlytics.instance.setCustomKey('last_deep_link_path', uri.path);

        if (host.contains("payment-success")) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            locator<NavigationService>().clearStackAndShow(Routes.paymentSuccessPage);
          });
        } else if (host.contains("payment-failed")) {
          locator<NavigationService>().clearStackAndShow(Routes.orderList);
        }
      },
      customData: {
        'uri': uri.toString(),
        'host': uri.host,
        'path': uri.path,
        'operation': 'deep_link_navigation',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      context: 'MyApp Root',
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Log auth state changes
          if (snapshot.hasError) {
            ComprehensiveErrorHandler.reportError(
              error: snapshot.error!,
              stackTrace: StackTrace.current,
              context: 'Firebase Auth stream error',
              customData: {'operation': 'auth_stream'},
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Center(child: CircularProgressIndicator()),
              debugShowCheckedModeBanner: false,
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            FirebaseCrashlytics.instance.setUserIdentifier(snapshot.data!.uid);
            developer.log('👤 User authenticated: ${snapshot.data!.uid}', name: 'Auth');
          } else {
            developer.log('👤 User not authenticated', name: 'Auth');
          }

          return ErrorBoundary(
            context: 'Theme Builder',
            child: ValueListenableBuilder<AppUiModes>(
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
                  ErrorWidget.builder = (FlutterErrorDetails details) {
                    ComprehensiveErrorHandler.reportError(
                      error: details.exception,
                      stackTrace: details.stack ?? StackTrace.current,
                      context: 'Widget build error',
                      customData: {
                        'widget_details': details.toString(),
                        'operation': 'widget_build',
                      },
                    );

                    if (kDebugMode) {
                      return Container(
                        color: Colors.red.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error, color: Colors.white, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                'Widget Error Detected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  details.exception.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final errors = ComprehensiveErrorHandler.getErrorLog();
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Error Log'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        height: 300,
                                        child: ListView.builder(
                                          itemCount: errors.length,
                                          itemBuilder: (_, index) => Text(
                                            errors[index],
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('View Error Log'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Material(
                      child: Center(
                        child: Text('Something went wrong'),
                      ),
                    );
                  };

                  return widget ?? const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
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
    ComprehensiveErrorHandler.wrapWithErrorHandling(
      operationName: 'Show update dialog',
      operation: () async {
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
      },
      customData: {'operation': 'show_update_dialog'},
    );
  }
}