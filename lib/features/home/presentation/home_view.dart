import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_ph/features/home/presentation/widgets/bottom_nav_bar.dart';

import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark ? kcDarkBgGradient : kcLightBgGradient;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: viewModel.currentPage,
      ),
      bottomNavigationBar: BottomNavBar(viewModel: viewModel),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    if (userLoggedIn.value == true) {
      viewModel.fetchDeliveredOrders();
      viewModel.fetchOnlineCart();
      viewModel.fetchPayNowOrder();
    }
    super.onViewModelReady(viewModel);
  }
}
