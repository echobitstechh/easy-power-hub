import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/models/profile.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();


  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    String? token = await locator<LocalStorage>().fetch(LocalStorageDir.authToken);
    String? user = await locator<LocalStorage>().fetch(LocalStorageDir.authUser);
    bool? onboarded = await locator<LocalStorage>().fetch(LocalStorageDir.onboarded);
    //bool? onboarded = false;
    if (onboarded == null || onboarded == false) {
      _navigationService.replaceWithOnboardingView();
    } else {
      if (token != null && user != null) {
        userLoggedIn.value = true;
        profile.value = Profile.fromJson(Map<String, dynamic>.from(jsonDecode(user)));
      }
      _navigationService.replaceWithHomeView();
      // _navigationService.replaceWithAuthView();
    }
  }



}
