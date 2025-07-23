import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static bool _isInitialized = false;

  /// Initialize crash reporting service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Enable crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Set up Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        // Log to console in debug mode
        if (kDebugMode) {
          FlutterError.presentError(details);
          developer.log(
            '🔴 FLUTTER ERROR: ${details.exception}',
            name: 'CrashlyticService',
            error: details.exception,
            stackTrace: details.stack,
          );
        }

        // Report to crash services
        _crashlytics.recordFlutterFatalError(details);
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      };

      _isInitialized = true;
      log('CrashlyticsService initialized successfully');
    } catch (e, stack) {
      developer.log(
        ' Failed to initialize CrashlyticsService: $e',
        name: 'CrashlyticsService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static void log(String message) {
    // Always log to console in debug mode
    if (kDebugMode) {
      developer.log('📋 $message', name: 'App');
    }

    try {
      _crashlytics.log(message);
      Sentry.captureMessage(message);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to log message: $e', name: 'CrashlyticsService');
      }
    }
  }

  static Future<void> recordError(
      dynamic exception,
      StackTrace? stack, {
        String? reason,
        bool fatal = false,
        Map<String, dynamic>? customData,
      }) async {
    // Enhanced logging for debug mode
    if (kDebugMode) {
      developer.log(
        '🔥 ${fatal ? 'FATAL ' : ''}ERROR: $exception',
        name: 'CrashlyticsService',
        error: exception,
        stackTrace: stack,
      );

      if (reason != null) {
        developer.log('📝 Reason: $reason', name: 'CrashlyticsService');
      }
    }

    try {
      final frame = _getFirstAppFrame(stack);

      // Set custom keys for better debugging
      final customKeys = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'is_fatal': fatal,
        if (reason != null) 'reason': reason,
        if (frame != null) ...{
          'file': frame.uri.pathSegments.last,
          'line': frame.line ?? 'unknown',
          'function': frame.member ?? 'unknown',
        },
        if (customData != null) ...customData,
      };

      // Set all custom keys
      for (final entry in customKeys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }

      // Log detailed message
      final logMessage = [
        'Error from ${frame?.member ?? 'unknown'}',
        if (frame != null) 'in ${frame.uri.pathSegments.last}:${frame.line}',
        if (reason != null) '- $reason',
      ].join(' ');

      _crashlytics.log(logMessage);

      // Record to Firebase Crashlytics
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        printDetails: kDebugMode,
        fatal: fatal,
      );

      // Record to Sentry with additional context
      await Sentry.captureException(
        exception,
        stackTrace: stack,
        withScope: (scope) {
          // Set tags and extras
          if (reason != null) scope.setTag('reason', reason);
          scope.setTag('is_fatal', fatal.toString());
          if (frame != null) {
            scope.setTag('file', frame.uri.pathSegments.last);
            scope.setTag('line', frame.line?.toString() ?? 'unknown');
            scope.setTag('function', frame.member ?? 'unknown');
          }
          for (final entry in customKeys.entries) {
            scope.setExtra(entry.key, entry.value);
          }
        },
      );

    } catch (e, s) {
      if (kDebugMode) {
        developer.log(
          'Failed to record error: $e',
          name: 'CrashlyticsService',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  static Future<void> recordFatalError(
      dynamic exception,
      StackTrace? stack, {
        String? reason,
        Map<String, dynamic>? customData,
      }) async {
    await recordError(
      exception,
      stack,
      reason: reason,
      fatal: true,
      customData: customData,
    );
  }

  /// Record a handled exception (non-fatal)
  static Future<void> recordHandledException(
      dynamic exception,
      StackTrace? stack, {
        String? reason,
        Map<String, dynamic>? customData,
      }) async {
    await recordError(
      exception,
      stack,
      reason: reason,
      fatal: false,
      customData: customData,
    );
  }

  static Frame? _getFirstAppFrame(StackTrace? stack) {
    if (stack == null) return null;

    try {
      final chain = Chain.forTrace(stack);
      final frames = chain.toTrace().frames;

      // Try to find a frame from your app (not from Flutter framework or packages)
      return frames.firstWhere(
            (f) => f.uri.scheme == 'file' &&
            !f.uri.path.contains('/flutter/') &&
            !f.uri.path.contains('/.pub-cache/'),
        orElse: () => frames.firstWhere(
              (f) => f.uri.scheme == 'file',
          orElse: () => frames.isNotEmpty ? frames.first : Frame.caller(),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: userId));
      });

      log('User ID set: $userId');
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set user ID: $e', name: 'CrashlyticsService');
      }
    }
  }

  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      final val = value is String || value is num || value is bool
          ? value
          : value.toString();

      await _crashlytics.setCustomKey(key, val);
      await Sentry.configureScope((scope) {
        scope.setTag(key, val.toString());
      });

      if (kDebugMode) {
        developer.log('Custom key set: $key = $val', name: 'CrashlyticsService');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set custom key: $e', name: 'CrashlyticsService');
      }
    }
  }

  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      log('Crashlytics collection enabled: $enabled');
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set crashlytics collection: $e', name: 'CrashlyticsService');
      }
    }
  }

  /// Test crash reporting - use only for testing!
  static void testCrash() {
    if (kDebugMode) {
      throw Exception('Test crash from CrashlyticsService');
    }
  }

  /// Test non-fatal error reporting
  static void testNonFatalError() {
    recordHandledException(
      Exception('Test non-fatal error'),
      StackTrace.current,
      reason: 'Testing error reporting functionality',
      customData: {'test': true, 'timestamp': DateTime.now().toIso8601String()},
    );
  }
}