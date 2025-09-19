import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/app_colors.dart';
import 'startup_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      StartupViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: 600,
                  color: kcClipColor,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset(
                  "assets/images/easy_ph_logo.png",
                  height: 120,
                  width: 120,
                ),
              ),
            ),
          ],

        )
    );
  }

  @override
  StartupViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    // Start from top-left corner
    path.lineTo(0, size.height - 300);
    // Create a quadratic bezier curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 0,
    );
    // Line to the top-right corner
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
