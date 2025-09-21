import 'package:flutter/material.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:easy_ph/ui/components/profile_picture.dart';
import '../../../state.dart';
import '../profile_viewModel.dart';

class ProfilePictureSection extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfilePictureSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector( // This single GestureDetector is sufficient
          onTap: viewModel.showProfileDetailBottomSheet,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              ProfilePicture(size: 100, url: profile.value.profilePicture),
              // The inner GestureDetector is now removed
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: kcPrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: kcWhiteColor, width: 2),
                ),
                child: const Icon(Icons.remove_red_eye_outlined, color: kcWhiteColor, size: 18),
              ),
            ],
          ),
        ),
        verticalSpaceSmall,
        Text(
          "${profile.value.firstName} ${profile.value.lastName}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}