import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';

class OnboardingView3 extends StatefulWidget {
  const OnboardingView3({super.key});

  @override
  State<OnboardingView3> createState() => _OnboardingViewState();
}

bool isloading = false;
final LocalStorage _localStorage = locator<LocalStorage>();

class _OnboardingViewState extends State<OnboardingView3> {
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
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SvgPicture.asset(
                      'assets/images/addresspic.svg', // Replace with your asset path
                      height: 400,
                    ),
                  ),
                  verticalSpaceLarge,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Anywhere, Anytime",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We're here for you, wherever you are! Reach out to us from anywhere for seamless support and services.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpaceMedium,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubmitButton(
                      isLoading: false,
                      boldText: true,
                      label: "GET STARTED",
                      submit: () async {
                        await _localStorage.save(
                            LocalStorageDir.onboarded, true);
                        locator<NavigationService>().clearStackAndShow(Routes.homeView);
                      },
                      color: kcPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(26.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IndicatorDot(isActive: false),
                    SizedBox(width: 8),
                    IndicatorDot(isActive: false),
                    SizedBox(width: 8),
                    IndicatorDot(isActive: true),
                  ],
                ),
              ),
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

class IndicatorDot extends StatelessWidget {
  final bool isActive;
  const IndicatorDot({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
