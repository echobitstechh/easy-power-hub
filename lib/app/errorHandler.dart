import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ComprehensiveErrorHandler {
  static bool _isInitialized = false;
  static final List<String> _errorLog = [];

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Capture Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        _logError('FLUTTER_FRAMEWORK_ERROR', details.exception, details.stack, details.toString());
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // 2. Capture platform dispatcher errors (newer Flutter versions)
      PlatformDispatcher.instance.onError = (error, stack) {
        _logError('PLATFORM_DISPATCHER_ERROR', error, stack, 'Platform dispatcher error');
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // 3. Capture Dart unhandled exceptions
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          final error = errorAndStacktrace[0];
          final stack = StackTrace.fromString(errorAndStacktrace[1].toString());

          _logError('ISOLATE_ERROR', error, stack, 'Unhandled isolate error');
          await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }).sendPort,
      );

      // 4. Override print to catch and log all prints
      if (kDebugMode) {
        debugPrint = (String? message, {int? wrapWidth}) {
          developer.log(message ?? '', name: 'APP_DEBUG');
          // Also keep original functionality
          debugPrintThrottled(message, wrapWidth: wrapWidth);
        };
      }

      _isInitialized = true;
      developer.log('✅ Comprehensive error handler initialized', name: 'ErrorHandler');

    } catch (e, stack) {
      developer.log('❌ Failed to initialize error handler: $e',
          name: 'ErrorHandler', error: e, stackTrace: stack);
    }
  }

  static void _logError(String type, dynamic error, StackTrace? stack, String context) {
    final timestamp = DateTime.now().toIso8601String();
    final errorMsg = '[$timestamp] $type: $error\nContext: $context\nStack: $stack';

    _errorLog.add(errorMsg);

    // Keep only last 50 errors in memory
    if (_errorLog.length > 50) {
      _errorLog.removeAt(0);
    }

    // Always log to developer console
    developer.log('💥 $type: $error',
        name: 'CrashDetected',
        error: error,
        stackTrace: stack
    );

    // Also print to regular console
    print('🔴 CRASH DETECTED [$type]: $error');
    if (stack != null) {
      print('📍 Stack trace: $stack');
    }
  }

  /// Get all logged errors for debugging
  static List<String> getErrorLog() => List.unmodifiable(_errorLog);

  /// Clear the error log
  static void clearErrorLog() => _errorLog.clear();

  /// Manual error reporting for custom catches
  static Future<void> reportError({
    required dynamic error,
    required StackTrace stackTrace,
    required String context,
    Map<String, dynamic>? customData,
    bool fatal = false,
  }) async {
    _logError('MANUAL_REPORT', error, stackTrace, context);

    try {
      // Set custom keys
      if (customData != null) {
        for (final entry in customData.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
        }
      }

      await FirebaseCrashlytics.instance.setCustomKey('custom_context', context);
      await FirebaseCrashlytics.instance.setCustomKey('timestamp', DateTime.now().toIso8601String());

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: context,
        fatal: fatal,
        printDetails: true,
      );

      developer.log('✅ Error reported successfully', name: 'ErrorHandler');

    } catch (e, s) {
      developer.log('❌ Failed to report error: $e',
          name: 'ErrorHandler', error: e, stackTrace: s);
    }
  }

  /// Wrap any function with error handling
  static Future<T?> wrapWithErrorHandling<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, dynamic>? customData,
  }) async {
    try {
      developer.log('▶️ Starting: $operationName', name: 'Operation');
      final result = await operation();
      developer.log('✅ Completed: $operationName', name: 'Operation');
      return result;
    } catch (error, stackTrace) {
      await reportError(
        error: error,
        stackTrace: stackTrace,
        context: 'Error in $operationName',
        customData: {
          'operation_name': operationName,
          ...?customData,
        },
        fatal: false,
      );
      return null;
    }
  }

  /// Test all error reporting mechanisms
  static Future<void> testAllErrorTypes() async {
    if (!kDebugMode) return;

    developer.log('🧪 Testing all error types...', name: 'ErrorHandler');

    // Test 1: Manual error report
    await Future.delayed(const Duration(seconds: 1));
    await reportError(
      error: Exception('Test manual error report'),
      stackTrace: StackTrace.current,
      context: 'Testing manual error reporting',
      customData: {'test_type': 'manual_report'},
    );

    // Test 2: Async error
    await Future.delayed(const Duration(seconds: 2));
    Timer(const Duration(milliseconds: 100), () {
      throw Exception('Test async timer error');
    });

    // Test 3: Future error
    await Future.delayed(const Duration(seconds: 3));
    Future.delayed(const Duration(milliseconds: 100), () {
      throw Exception('Test future delayed error');
    });

    // Test 4: Isolate spawn error (be careful with this one)
    await Future.delayed(const Duration(seconds: 4));
    try {
      await Isolate.spawn(_isolateEntryPoint, 'test data');
    } catch (e, s) {
      await reportError(
        error: e,
        stackTrace: s,
        context: 'Isolate spawn test error',
        customData: {'test_type': 'isolate_spawn'},
      );
    }

    developer.log('🧪 All error tests dispatched', name: 'ErrorHandler');
  }

  static void _isolateEntryPoint(String message) {
    // This isolate will throw an error
    throw Exception('Test isolate error: $message');
  }
}

/// Widget wrapper that catches build errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String context;
  final Map<String, dynamic>? customData;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.context,
    this.customData,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          // Report the error
          ComprehensiveErrorHandler.reportError(
            error: error,
            stackTrace: stackTrace,
            context: 'Widget build error in $context',
            customData: {
              'widget_context': this.context,
              ...?customData,
            },
          );

          // Return error widget
          if (kDebugMode) {
            return Container(
              color: Colors.red.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Error in $context',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}

/// Extension for easy error wrapping
extension SafeAsync on Future {
  Future<T?> catchAndReport<T>(String context, [Map<String, dynamic>? customData]) async {
    try {
      return await this as T;
    } catch (error, stackTrace) {
      await ComprehensiveErrorHandler.reportError(
        error: error,
        stackTrace: stackTrace,
        context: context,
        customData: customData,
      );
      return null;
    }
  }
}