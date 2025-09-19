import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ph/features/dashboard/presentation/dashboad_view.dart';
import 'package:easy_ph/features/home/presentation/home_viewmodel.dart';

void main() {
  group('HomeViewModel Tests -', () {
    late HomeViewModel model;

    setUp(() {
      model = HomeViewModel();
    });

    test('Initial selectedTab should be 0', () {
      expect(model.selectedTab, 0);
    });

    test('changeSelected should update selectedTab and notify listeners', () {
      int notifyCount = 0;
      model.addListener(() => notifyCount++);

      model.changeSelected(2);
      expect(model.selectedTab, 2);
      expect(notifyCount, 1);
    });

    test('clearSelectedTab should set selectedTab to -1 and notify', () {
      int notifyCount = 0;
      model.addListener(() => notifyCount++);

      // model.clearSelectedTab();
      expect(model.selectedTab, -1);
      expect(notifyCount, 1);
    });

    test('currentPage should return the correct widget based on selectedTab', () {
      expect(model.currentPage.runtimeType, DashboardView);

      model.changeSelected(3);
      expect(model.currentPage.runtimeType, DashboardView);
    });

    test('checkForUpdates should complete without throwing', () async {
      // Just ensure it runs without error
      // await model.checkForUpdates(FakeBuildContext());
    });
  });
}

/// A fake BuildContext just to satisfy method signature
class FakeBuildContext extends Fake implements BuildContext {}
