
import 'package:flutter/material.dart';
import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/profile_picture_picker.dart';
import '../profile_viewModel.dart';

class ProfileDetailsView extends StatelessWidget {
  final ProfileViewModel viewModel;
  const ProfileDetailsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kcDarkGreyColor
          : kcWhiteColor,
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: const Text('Profile Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          ProfilePicturePicker(
            selectedFile: viewModel.selectedFile,
            onImagePicked: (file) => viewModel.updateProfileImage(file),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileDetailTile(
                        context,
                        title: 'Full Name',
                        subtitle: "${profile.value.firstName} ${profile.value.lastName}",
                        onEdit: () => viewModel.showEditProfileDialog(context),
                      ),
                      _buildProfileDetailTile(
                        context,
                        title: 'Email Address',
                        subtitle: '${profile.value.email}',
                        onEdit: null,
                      ),
                      _buildProfileDetailTile(
                        context,
                        title: 'Phone Number',
                        subtitle: "${profile.value.phoneNumber}",
                        onEdit: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        VoidCallback? onEdit,
      }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 10),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: onEdit != null
          ? IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
      )
          : null,
    );
  }
}