
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:wahala_hq/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'home_viewmodel.dart';


class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      HomeViewModel viewModel,
      Widget? child,
      ) {

    return Scaffold(
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
    super.onViewModelReady(viewModel);
  }
}

