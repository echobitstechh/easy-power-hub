import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_ph/features/auth/presentation/widgets/login_form.dart';
import 'package:easy_ph/features/auth/presentation/widgets/otp_form.dart';
import 'package:easy_ph/features/auth/presentation/widgets/register_form.dart';

import 'auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  final bool showLogin;

  const AuthView({super.key, this.showLogin = false});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late AuthViewModel _cachedViewModel;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.init(vsync: this);
        _cachedViewModel = viewModel;

        // Optionally jump to login screen on start
        if (widget.showLogin) {
          viewModel.goToLogin();
        }
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/wahala_small.png', fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -200) {
                        _cachedViewModel.flipForward();
                      } else if (details.primaryVelocity! > 200) {
                        _cachedViewModel.flipBackward();
                      }
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotate,
                        builder: (context, _) {
                          return Transform(
                            transform: Matrix4.rotationY(3.14 * rotate.value),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(viewModel.currentIndex),
                      child: getAuthPanel(viewModel.currentIndex),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getAuthPanel(int index) {
    switch (index) {
      case 0:
        return const RegisterForm();
      case 1:
        return const LoginForm();
      case 2:
        return const OtpForm();
      default:
        return const RegisterForm();
    }
  }
}
