import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.dialogs.dart';
import '../../app/app.locator.dart';
import 'remote_config_service.dart';

class UpdateService {
  final _remoteConfig = locator<RemoteConfigService>();
  final _dialogService = locator<DialogService>();

  Future<void> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final latestVersion = _remoteConfig.latestVersion;
      final minimumVersion = _remoteConfig.minimumVersion;
      final forceUpdate = _remoteConfig.forceUpdate;
      final updateMessage = _remoteConfig.updateMessage;

      // Check if update is available
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        final isForceUpdate = forceUpdate || 
            _isUpdateRequired(currentVersion, minimumVersion);

        await _showUpdateDialog(
          message: updateMessage,
          isForceUpdate: isForceUpdate,
        );
      }
    } catch (e) {
      print('Error checking for update: $e');
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    try {
      return _compareVersions(current, latest) < 0;
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  bool _isUpdateRequired(String current, String minimum) {
    try {
      return _compareVersions(current, minimum) < 0;
    } catch (e) {
      print('Error comparing minimum version: $e');
      return false;
    }
  }

  int _compareVersions(String version1, String version2) {
    // Remove build number if present (e.g., "1.0.0+1" becomes "1.0.0")
    final cleanVersion1 = version1.split('+').first;
    final cleanVersion2 = version2.split('+').first;

    final v1Parts = cleanVersion1.split('.').map((part) {
      try {
        return int.parse(part);
      } catch (e) {
        print('Error parsing version part: $part');
        return 0;
      }
    }).toList();

    final v2Parts = cleanVersion2.split('.').map((part) {
      try {
        return int.parse(part);
      } catch (e) {
        print('Error parsing version part: $part');
        return 0;
      }
    }).toList();

    // Ensure both have at least 3 parts
    while (v1Parts.length < 3) v1Parts.add(0);
    while (v2Parts.length < 3) v2Parts.add(0);

    for (int i = 0; i < 3; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1 < v2) return -1;
      if (v1 > v2) return 1;
    }

    return 0;
  }

  Future<void> _showUpdateDialog({
    required String message,
    required bool isForceUpdate,
  }) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.update,
      barrierDismissible: !isForceUpdate,
      data: {
        'message': message,
        'forceUpdate': isForceUpdate,
      },
    );
  }
}