
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';

class OnboardingViewModel extends BaseViewModel {
  final pageController = PageController();

  void init() async {
    await locator<LocalStorage>().save(LocalStorageDir.onboarded, true);
  }

  List<Widget> pages = const [
    //PageOne(),
    // PageTwo(),
  ];
  int currentPage = 0;

  void onPageChanged(int i) {
    currentPage = i;
    rebuildUi();
  }

  void lastPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }
}
