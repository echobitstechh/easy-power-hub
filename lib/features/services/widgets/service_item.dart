
import '../../../core/data/models/service.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/glass/glass_button.dart';
import 'package:stacked_services/stacked_services.dart';
import '../services_viewmodel.dart';

class ServiceItem extends StatelessWidget {
  final Service service;
  final ServicesviewModel viewModel;

  const ServiceItem({
    Key? key,
    required this.service,
    required this.viewModel,
  }) : super(key: key);

  void _showSignInSheet(BuildContext context) {
    final isDark = uiMode.value == AppUiModes.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.lock_open_rounded, size: 40, color: kcSecondaryColor),
            const SizedBox(height: 16),
            Text(
              'Sign in to continue',
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or sign in to request\na service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Sign In',
                height: 52,
                onTap: () {
                  Navigator.pop(context);
                  locator<NavigationService>().navigateTo(Routes.login);
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe later',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: service.image ?? 'https://via.placeholder.com/120',
                fit: BoxFit.cover,
                height: 90,
                width: 86,
                placeholder: (context, url) => Container(
                  color: uiMode.value == AppUiModes.dark ? Colors.grey[700] : Colors.grey[200],
                  height: 90,
                  width: 86,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  color: uiMode.value == AppUiModes.dark ? Colors.grey[700] : Colors.grey[200],
                  height: 90,
                  width: 86,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: GoogleFonts.redHatDisplay(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  Text(
                    service.description ?? 'No description available',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  ElevatedButton(
                    onPressed: () {
                      if (!userLoggedIn.value) {
                        _showSignInSheet(context);
                      } else {
                        viewModel.requestSpecificService(service);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Request Service',
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}