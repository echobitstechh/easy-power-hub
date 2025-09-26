// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/address_sheet/add_address_bottom_sheet.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/order_status/order_status_timeline.dart';
import '../ui/bottom_sheets/profile_screen_sheet.dart';

enum BottomSheetType {
  notice,
  profileScreen,
  orderStatusTimeline,
  addAddressBottom,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.profileScreen: (context, request, completer) =>
        ProfileScreenSheet(request: request, completer: completer),
    BottomSheetType.orderStatusTimeline: (context, request, completer) =>
        OrderStatusTimelineSheet(request: request, completer: completer),
    BottomSheetType.addAddressBottom: (context, request, completer) =>
        AddAddressBottomSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
