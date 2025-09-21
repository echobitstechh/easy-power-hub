
import 'package:easy_ph/features/auth/presentation/widgets/login.dart';
import 'package:easy_ph/features/auth/presentation/widgets/otp_form.dart';
import 'package:easy_ph/features/auth/presentation/widgets/register.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/app_colors.dart';
import 'auth_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024

enum PresentPage {
  login,
  register,
  signup,
}

class AuthView extends StackedView<AuthViewModel> {
  final PresentPage? initialPage;
  final Map<String, dynamic>? parametersArg;

  const AuthView({super.key, this.initialPage, this.parametersArg});

  @override
  Widget builder(
      BuildContext context,
      AuthViewModel viewModel,
      Widget? child,
      ) {
    // Determine the current page to display
    final currentWidget = switch (viewModel.presentPage) {
      PresentPage.login => const Login(),
      PresentPage.signup => OTPView(
        isOtpRequested: viewModel.isOtpRequested,
        userId: parametersArg?['userId'],
        verificationCode: parametersArg?['verificationCode'],
        phone: parametersArg?['phone'],
        email: parametersArg?['email'],
      ),
      PresentPage.register => const Register(),
    };

    return Scaffold(
      body: Stack(
        children: [
          // Top Decorative Background
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: CurvedClipper(),
              child: Container(
                height: 300,
                color: kcClipColor,
              ),
            ),
          ),
          // Main Content
          CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: currentWidget,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(AuthViewModel viewModel) {
    if (initialPage != null) {
      viewModel.setPresentPage(initialPage!);
      if (parametersArg != null) {
        viewModel.setParameters(parametersArg!);
      }
    }
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 300);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 0,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}