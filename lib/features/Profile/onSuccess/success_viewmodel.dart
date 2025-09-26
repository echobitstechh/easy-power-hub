
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class PaymentSuccessViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void onContinueShopping() {
    _navigationService.clearStackAndShow(Routes.homeView);
  }
}