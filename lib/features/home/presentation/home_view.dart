import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:wahala_hq/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:wahala_hq/features/home/presentation/widgets/drawer.dart';
import 'package:wahala_hq/features/home/presentation/widgets/header.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      drawer: const HomeDrawer(),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => Column(
          children: [
            HomeHeader(openDrawer: () {
              Scaffold.of(context).openDrawer();
            }),
            Expanded(child: viewModel.currentPage),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(viewModel: viewModel),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
