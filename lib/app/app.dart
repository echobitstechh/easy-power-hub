import 'package:afriprize/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:afriprize/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:afriprize/ui/views/home/home_view.dart';
import 'package:afriprize/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:afriprize/ui/views/onboarding/onboarding_view.dart';
import 'package:afriprize/ui/views/auth/auth_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: OnboardingView),
    MaterialRoute(page: AuthView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
