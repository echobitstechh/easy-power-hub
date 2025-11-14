import '../../app/app.locator.dart';
import '../services/remote_config_service.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class AppConfig {

  static const String baseUrl = "https://easyph.echobitsone.com/api/v1/";
  static const String appName = "Easy PH";
  static const String appVersion = "1.0.0";
  static const String _fallbackLiveKey = 'pk_live_540bdf095640f7765b0a822f08161087b68df565';
  static const String _fallbackTestKey = 'pk_test_6dacffb10a1fe6c809a81ee5e1e9d7d2076b5b6d';
  static const String APPLESTOREURL = 'https://apps.apple.com/ng/app/easy-power-hub/id6746103255';
  static const String GOOGLESTOREURL = 'https://play.google.com/store/apps/details?id=com.echobitstech.easyph&pcampaignid=web_share';

  static String get paystackApiKey {
    try {
      final remoteConfig = locator<RemoteConfigService>();
      if (remoteConfig.initialized) {
        return remoteConfig.activePaystackKey;
      }
    } catch (e) {
      print('Failed to get Remote Config key: $e');
    }
    print('⚠️ Using Fallback Paystack Key');
    return _fallbackLiveKey;
  }

  static String get paystackApiKeyTest {
    try {
      final remoteConfig = locator<RemoteConfigService>();
      if (remoteConfig.initialized) {
        return remoteConfig.paystackTestKey;
      }
    } catch (e) {
      print('Failed to get Remote Config key: $e');
    }
    return _fallbackTestKey;
  }

}
