import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../common/app_colors.dart';

class IncompleteBiodataDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const IncompleteBiodataDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? kcPrimaryColor.withValues(alpha: 0.2)
                : kcPrimaryColor.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: kcPrimaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kcPrimaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
                border: Border.all(
                  color: kcPrimaryColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 32,
                color: kcPrimaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              request.title ?? 'Profile Incomplete',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'HostGrotesk',
                color: isDark ? kcWhiteColor : kcBlackColor,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              request.description ??
                  'Your account is verified but your profile details are incomplete. Complete your biodata to start using the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                fontFamily: 'HostGrotesk',
                color: isDark
                    ? kcWhiteColor.withValues(alpha: 0.6)
                    : kcMediumGrey,
              ),
            ),

            const SizedBox(height: 28),

            // Primary CTA — Go to Biodata Page
            GestureDetector(
              onTap: () => completer(DialogResponse(confirmed: true)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kcPrimaryColor,
                      kcPrimaryColor.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kcPrimaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Go to Biodata Page',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'HostGrotesk',
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary — Cancel
            GestureDetector(
              onTap: () => completer(DialogResponse(confirmed: false)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isDark
                      ? kcWhiteColor.withValues(alpha: 0.06)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'HostGrotesk',
                    color: isDark
                        ? kcWhiteColor.withValues(alpha: 0.6)
                        : kcMediumGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
