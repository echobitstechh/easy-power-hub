
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/app_fonts.dart';
import 'dashboard_viewmodel.dart';


class DashboardView extends StackedView<DashboardViewModel> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      DashboardViewModel viewModel,
      Widget? child,
      ) {

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: hostGrotesk,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) => DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
  }
}

