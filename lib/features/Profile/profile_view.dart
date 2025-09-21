
import 'package:easy_ph/features/Profile/profile_viewModel.dart';
import 'package:easy_ph/features/Profile/widgets/profile_picture_section.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../state.dart';
import '../../ui/common/app_colors.dart';
import '../../ui/common/ui_helpers.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile"),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ProfilePictureSection(viewModel: viewModel), // Extracted widget
                verticalSpaceMedium,
                _buildActionList(context, viewModel),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSignOutAndDeleteSection(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context, ProfileViewModel viewModel) {
    return Column(
      children: [
        // ListTile(
        //   onTap: viewModel.navigateToWallet,
        //   leading: const Icon(Icons.wallet, color: kcOrangeColor),
        //   title: const Text("Wallet"),
        // ),
        // ListTile(
        //   onTap: viewModel.navigateToOrders,
        //   leading: const Icon(Icons.fire_truck_rounded, color: kcPrimaryColor),
        //   title: const Text("My orders"),
        // ),
        // ListTile(
        //   onTap: viewModel.navigateToShippingAddresses,
        //   leading: const Icon(Icons.location_on, color: kcOrangeColor),
        //   title: const Text("Shipping addresses"),
        // ),
        // ListTile(
        //   onTap: viewModel.navigateToSupport,
        //   leading: const Icon(Icons.support_agent, color: kcOrangeColor),
        //   title: const Text("Support"),
        // ),
        // ListTile(
        //   onTap: viewModel.navigateToChangePassword,
        //   leading: const Icon(Icons.lock, color: kcOrangeColor),
        //   title: const Text("Change password"),
        // ),
        ListTile(
          onTap: viewModel.toggleUiMode,
          leading: const Icon(Icons.light_mode_sharp, color: kcOrangeColor),
          title: const Text("Dark Theme"),
          trailing: ValueListenableBuilder<AppUiModes>(
            valueListenable: uiMode,
            builder: (context, value, child) => Switch(
              value: value == AppUiModes.dark,
              onChanged: (val) => viewModel.toggleUiMode(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutAndDeleteSection(ProfileViewModel viewModel) {
    return Column(
      children: [
        ListTile(
          onTap: viewModel.onSignOut,
          leading: const Icon(Icons.logout, color: kcOrangeColor),
          title: const Text("Sign Out"),
        ),
        verticalSpaceMedium,
        Center(
          child: Opacity(
            opacity: 0.4,
            child: GestureDetector(
              onTap: viewModel.onSignOut,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Delete Account", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(ProfileViewModel viewModel) {
    viewModel.getProfile();
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();
}