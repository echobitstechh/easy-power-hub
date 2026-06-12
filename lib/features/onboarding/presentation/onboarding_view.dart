import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/glass/glass_button.dart';
import '../../../ui/components/glass/glass_card.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = locator<LocalStorage>();
    final navService = locator<NavigationService>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Amber glow orb top-right
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kcPrimaryColor.withOpacity(isDark ? 0.25 : 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle orb bottom-left
              Positioned(
                bottom: 80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kcSecondaryColor.withOpacity(isDark ? 0.18 : 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    verticalSpaceMedium,

                    // Illustration
                    SizedBox(
                      height: size.height * 0.38,
                      child: SvgPicture.asset(
                        'assets/images/addresspic.svg',
                        fit: BoxFit.contain,
                      ),
                    ),

                    verticalSpaceMedium,

                    // Glass card wrapping the text + CTA
                    GlassCard(
                      borderRadius: 28,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Text(
                            "Anywhere, Anytime",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'HostGrotesk',
                              color: isDark ? kcWhiteColor : kcBlackColor,
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                            "We're here for you, wherever you are! "
                            "Reach out to us from anywhere for seamless support and services.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.55,
                              fontFamily: 'HostGrotesk',
                              color: isDark
                                  ? kcWhiteColor.withOpacity(0.65)
                                  : kcMediumGrey,
                            ),
                          ),
                          verticalSpaceMedium,

                          // CTA
                          SizedBox(
                            width: double.infinity,
                            child: GlassButton(
                              label: "Get Started",
                              onTap: () async {
                                await localStorage.save(
                                    LocalStorageDir.onboarded, true);
                                navService.clearStackAndShow(Routes.homeView);
                              },
                            ),
                          ),

                          verticalSpaceSmall,

                          // Single active dot indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Dot(isActive: false),
                              const SizedBox(width: 6),
                              _Dot(isActive: false),
                              const SizedBox(width: 6),
                              _Dot(isActive: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? kcPrimaryColor : kcLightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
