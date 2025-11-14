import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService with ListenableServiceMixin {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  
  bool _initialized = false;
  bool get initialized => _initialized;

  String get paystackLiveKey => _remoteConfig.getString('paystack_live_key');
  String get paystackTestKey => _remoteConfig.getString('paystack_test_key');
  bool get useLivePaystack => _remoteConfig.getBool('use_live_paystack');
  
  String get activePaystackKey => useLivePaystack ? paystackLiveKey : paystackTestKey;

  String get latestVersion => _remoteConfig.getString('latest_app_version');
  String get minimumVersion => _remoteConfig.getString('minimum_required_version');
  bool get forceUpdate => _remoteConfig.getBool('force_update');
  String get updateMessage => _remoteConfig.getString('update_message');
  
  Future<void> initialize() async {
    try {
      // Set config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 12),
        ),
      );

      await _remoteConfig.setDefaults({
        'paystack_live_key': 'pk_live_540bdf095640f7765b0a822f08161087b68df565',
        'paystack_test_key': 'pk_test_6dacffb10a1fe6c809a81ee5e1e9d7d2076b5b6d',
        'use_live_paystack': true,
        'latest_app_version': '22.0.0',
        'minimum_required_version': '22.0.0',
        'force_update': true,
        'update_message': 'A new version is available. Please update to continue enjoying the best experience.',
      });

      try {
        await _remoteConfig.fetchAndActivate();
      } catch (e) {
        print('Remote Config: Failed to fetch/activate: $e');
      }
      
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  // Method to refresh config manually
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      notifyListeners();
    } catch (e) {
      print('Failed to refresh Remote Config: $e');
    }
  }
}