import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final LocalStorage _localStorage = locator<LocalStorage>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background curved shape
            Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: 500,
                  color: kcClipColor,
                ),
              ),
            ),

            // Main content (full height, non-scrollable)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                    child: TextButton(
                      onPressed: () async {
                        await locator<LocalStorage>()
                            .save(LocalStorageDir.onboarded, true);
                        locator<NavigationService>()
                            .clearStackAndShow(Routes.homeView);
                      },
                      child: const Text("Skip",
                          style:
                              TextStyle(color: kcDarkGreyColor, fontSize: 16)),
                    ),
                  ),
                ),

                // Image and text
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/welcome.svg',
                      height: 300,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "Welcome to Easy Power Hub!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We're excited to have you here. Browse our comprehensive selection of solar solutions, electronics, and Lightening to find exactly what you need.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: SubmitButton(
                    isLoading: false,
                    boldText: true,
                    label: "GET STARTED",
                    submit: () async {
                      await _localStorage.save(LocalStorageDir.onboarded, true);
                      locator<NavigationService>()
                          .clearStackAndShow(Routes.homeView);
                    },
                    color: kcPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    // Start from top-left corner
    path.lineTo(0, size.height - 100);
    // Create a quadratic bezier curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 100,
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

