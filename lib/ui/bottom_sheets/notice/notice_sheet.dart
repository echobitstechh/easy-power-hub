import 'package:flutter/material.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:easy_ph/ui/components/glass/glass_bottom_sheet_bg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'notice_sheet_model.dart';

class NoticeSheet extends StackedView<NoticeSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const NoticeSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  @override
  Widget builder(BuildContext context, NoticeSheetModel viewModel, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBottomSheetBg(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? kcWhiteColor.withOpacity(0.25)
                    : kcMediumGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            request.title!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'HostGrotesk',
              color: isDark ? kcWhiteColor : kcBlackColor,
            ),
          ),
          verticalSpaceTiny,
          Text(
            request.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? kcWhiteColor.withOpacity(0.65) : kcMediumGrey,
            ),
            maxLines: 3,
            softWrap: true,
          ),
          verticalSpaceLarge,
        ],
      ),
    );
  }

  @override
  NoticeSheetModel viewModelBuilder(BuildContext context) => NoticeSheetModel();
}
