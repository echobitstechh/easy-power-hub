
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class OnboardingPageModel {
  final String title;
  final String description;

  OnboardingPageModel({
    required this.title,
    required this.description,
  });
}

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: "Speak Freely, Share Boldly",
      description:
      "Post your thoughts, experiences, and rants about politics, economy, culture, and more.",
    ),
    OnboardingPageModel(
      title: "Join a Supportive Community",
      description:
      "Comment, react, and discuss with others who care. Together, we can inspire change.",
    ),
    OnboardingPageModel(
      title: "Stay Informed and Safe",
      description:
      "We use AI moderation and reporting to keep the platform respectful. "
          "You can post anonymously or verify your account for more features.",
    ),
  ];

  int currentPage = 0;

  bool get isLastPage => currentPage == pages.length - 1;

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
    } else {
      currentPage++;
      rebuildUi();
    }
  }

  void finishOnboarding() {
    _navigationService.clearStackAndShow(Routes.login);
  }
}
