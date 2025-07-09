import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:wahala_hq/ui/common/app_colors.dart';
import '../../../state.dart';
import '../../../ui/components/submit_button.dart';
import 'onboarding_viewmodel.dart';

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, OnboardingViewModel viewModel, Widget? child) {
    final pages = viewModel.pages;
    final page = pages[viewModel.currentPage];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/wahala.png',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(viewModel.currentPage),
                padding: const EdgeInsets.all(44),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hankenGrotesk(
                        textStyle: TextStyle(
                          fontSize: 32, // Custom font size
                          fontWeight: FontWeight.w800, // Custom font weight
                          color: uiMode.value == AppUiModes.dark
                              ? Colors.white // Dark mode logo
                              : Colors.black,

                          // Custom text color (optional)
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hankenGrotesk(
                        textStyle: TextStyle(
                          fontSize: 16, // Custom font size
                          fontWeight: FontWeight.w300, // Custom font weight
                          color: uiMode.value == AppUiModes.dark
                              ? Colors.white // Dark mode logo
                              : Colors.black,

                          // Custom text color (optional)
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        final isActive = index == viewModel.currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? kcSecondaryColor : kcPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    SubmitButton(
                      isLoading: false,
                      label: viewModel.isLastPage ? 'Continue' : 'Next',
                      submit: viewModel.nextPage,
                      color: kcPrimaryColor,
                      boldText: true,
                      borderRadius: 32.0,
                      textSize: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) =>
      OnboardingViewModel();
}
