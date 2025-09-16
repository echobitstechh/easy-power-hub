
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
// import 'package:update_available/update_available.dart';
import 'package:wahala_hq/features/home/presentation/widgets/update_card.dart';
import '../../dashboard/presentation/dashboad_view.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// July, 2025
///

class HomeViewModel extends BaseViewModel {

  List<Widget> pages = [
     const DashboardView(),
     const DashboardView(),
     const DashboardView(),
     const DashboardView(),
  ];

  int selectedTab = 0;

  @override
  void dispose() {
    super.dispose();
  }

  HomeViewModel() {}

  void changeSelected(int index) {
    selectedTab = index;
    notifyListeners();
  }

  Widget get currentPage {
    return pages[selectedTab];
  }

  // Future<void> checkForUpdates(BuildContext context) async {
  //   final availability = await getUpdateAvailability();
  //   if (availability is UpdateAvailable) {
  //     const UpdateCard();
  //   }
  // }

  void clearSelectedTab() {
    selectedTab = -1;
    notifyListeners();
  }






}
