import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/common/app_colors.dart';

/// Replaces the GetX-based SnackbarService with a custom OverlayEntry that:
/// - Appears at the TOP of the screen (below status bar)
/// - Adapts to the current app theme (light / dark)
/// - Works directly with Flutter's navigator overlay — no GetX dependency
class AppSnackbarService extends SnackbarService {
  @override
  void showSnackbar({
    String title = '',
    required String message,
    Function(dynamic)? onTap,
    Duration? duration,
    String? mainButtonTitle,
    void Function()? onMainButtonTapped,
  }) {
    final navigatorState = StackedService.navigatorKey?.currentState;
    final overlay = navigatorState?.overlay;
    final context = StackedService.navigatorKey?.currentContext;
    if (overlay == null || context == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + 12,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                if (entry.mounted) entry.remove();
                onTap?.call(null);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? kcDarkGreyColor : const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? kcGlassBorderDark
                        : kcGlassBorderLight.withOpacity(0.15),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kcPrimaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title.isNotEmpty)
                            Text(
                              title,
                              style: const TextStyle(
                                color: kcWhiteColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'HostGrotesk',
                              ),
                            ),
                          Text(
                            message,
                            style: TextStyle(
                              color: kcWhiteColor.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'HostGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future.delayed(duration ?? const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}
