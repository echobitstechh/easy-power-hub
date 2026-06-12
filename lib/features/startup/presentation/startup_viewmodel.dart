import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/models/profile.dart';
import '../../../core/services/app_data_service.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';

class StartupViewModel extends BaseViewModel {
  final _nav     = locator<NavigationService>();
  final _storage = locator<LocalStorage>();
  final _appData = locator<AppDataService>();

  bool isComplete = false;
  bool _shouldGoHome = false;

  Future<void> runStartupLogic() async {
    final results = await Future.wait([
      _resolveAuth(),
      _appData.prefetch(),
    ]);

    _shouldGoHome = results[0] as bool;

    // Signal the view to play its completion animation.
    isComplete = true;
    notifyListeners();

    // Hold for the completion animation (fill + scale) to play out.
    await Future.delayed(const Duration(milliseconds: 900));

    if (_shouldGoHome) {
      _nav.replaceWithHomeView();
    }
  }

  /// Returns true if we should navigate to HomeView, false if we navigated
  /// elsewhere (onboarding).
  Future<bool> _resolveAuth() async {
    final token     = await _storage.fetch(LocalStorageDir.authToken);
    final user      = await _storage.fetch(LocalStorageDir.authUser);
    final onboarded = await _storage.fetch(LocalStorageDir.onboarded);

    if (onboarded == null || onboarded == false) {
      _nav.replaceWithOnboardingView();
      return false;
    }

    if (token != null && user != null) {
      userLoggedIn.value = true;
      profile.value =
          Profile.fromJson(Map<String, dynamic>.from(jsonDecode(user)));
    }

    return true;
  }
}
