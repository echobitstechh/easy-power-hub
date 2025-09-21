
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../features/Profile/profile_viewModel.dart';
import '../../features/Profile/widgets/profile_details.dart';

class ProfileScreenSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const ProfileScreenSheet({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget build(BuildContext context) {
    // You can pass the ViewModel to the sheet here.
    final viewModel = request.data as ProfileViewModel;

    return ProfileDetailsView(viewModel: viewModel);
  }
}