
import 'package:easyph/state.dart';
import 'package:easyph/ui/views/home/widgets/bottom_nav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      HomeViewModel viewModel,
      Widget? child,
      ) {
    viewModel.checkForUpdates(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DB),
      body: Stack(
        children: [
          viewModel.currentPage,
        ],
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
    }
    super.onViewModelReady(viewModel);
  }
}


