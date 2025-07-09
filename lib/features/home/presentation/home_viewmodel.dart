import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wahala_hq/features/home/presentation/widgets/update_card.dart';
import '../../../app/app.locator.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  List<Widget> pages = [
    // DashboardView(),
  ];

  int selectedTab = 0;

  @override
  void dispose() {
    super.dispose();
  }

  HomeViewModel() {}

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  //for test
  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void changeSelected(int index) {
    selectedTab = index;
    notifyListeners();
  }

  Widget get currentPage {
    return pages[selectedTab];
  }



  Future<void> checkForUpdates(BuildContext context) async {
    final availability = await getUpdateAvailability();
    if (availability is UpdateAvailable) {
      const UpdateCard();
    }
  }





}
