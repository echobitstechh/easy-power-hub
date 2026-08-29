import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../ui/common/app_colors.dart';
import '../utils/local_store_dir.dart';
import '../utils/local_stotage.dart';
import '../../state.dart';

// True while the session-expired dialog is on screen — prevents stacking.
bool _sessionDialogVisible = false;

/// Shows the "Session Expired" dialog at most once at a time.
/// Clears auth state and navigates to login when the user taps OK.
Future<void> showSessionExpiredDialog() async {
  if (_sessionDialogVisible) return;
  _sessionDialogVisible = true;

  final context = StackedService.navigatorKey?.currentContext;
  if (context == null) {
    _sessionDialogVisible = false;
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: kcPrimaryColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HostGrotesk',
                  color: isDark ? kcWhiteColor : kcBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your session has expired. Please log in again to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'HostGrotesk',
                  color: isDark
                      ? kcWhiteColor.withOpacity(0.6)
                      : kcMediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    foregroundColor: kcWhiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'HostGrotesk',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  _sessionDialogVisible = false;

  // Clear auth state and go to login.
  userLoggedIn.value = false;
  final storage = locator<LocalStorage>();
  await storage.delete(LocalStorageDir.authToken);
  await storage.delete(LocalStorageDir.authUser);
  await storage.delete(LocalStorageDir.authRefreshToken);
  locator<NavigationService>().clearStackAndShow(Routes.login);
}
