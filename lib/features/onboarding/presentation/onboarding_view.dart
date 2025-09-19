import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/submit_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = locator<LocalStorage>();
    final navService = locator<NavigationService>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Curved background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: size.height * 0.55,
                  color: kcClipColor,
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// SVG Illustration
                  SizedBox(
                    height: size.height * 0.35,
                    child: SvgPicture.asset(
                      'assets/images/addresspic.svg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  verticalSpaceLarge,

                  /// Title & Subtitle
                  Text(
                    "Anywhere, Anytime",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We're here for you, wherever you are! "
                        "Reach out to us from anywhere for seamless support and services.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  verticalSpaceLarge,

                  /// Get Started Button
                  SubmitButton(
                    isLoading: false,
                    boldText: true,
                    label: "GET STARTED",
                    submit: () async {
                      await localStorage.save(LocalStorageDir.onboarded, true);
                      navService.clearStackAndShow(Routes.homeView);
                    },
                    color: kcPrimaryColor,
                  ),

                  verticalSpaceLarge,

                  /// Indicator Dots
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IndicatorDot(isActive: false),
                      SizedBox(width: 8),
                      IndicatorDot(isActive: false),
                      SizedBox(width: 8),
                      IndicatorDot(isActive: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curved Background
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 100)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 100,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Dot Indicator
class IndicatorDot extends StatelessWidget {
  final bool isActive;
  const IndicatorDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 14 : 10,
      height: isActive ? 14 : 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
