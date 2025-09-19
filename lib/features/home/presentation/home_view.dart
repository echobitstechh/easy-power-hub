
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_ph/features/home/presentation/widgets/bottom_nav_bar.dart';

import '../../../core/data/models/cart_item.dart';
import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
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

        return Scaffold(
          backgroundColor: kcBackgroundColor,
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

