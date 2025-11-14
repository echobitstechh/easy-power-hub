import 'package:easy_ph/core/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../common/app_colors.dart';

class UpdateDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const UpdateDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isForceUpdate = request.data?['forceUpdate'] ?? false;
    final String message = request.data?['message'] ?? 
        'A new version is available. Please update to continue.';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update_alt,
                size: 48,
                color: kcPrimaryColor,
              ),
            ),
            const SizedBox(height: 24), 

            // Title
            Text(
              isForceUpdate ? 'Update Required' : 'Update Available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                if (!isForceUpdate)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => completer(DialogResponse(confirmed: false)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Later'),
                    ),
                  ),
                if (!isForceUpdate) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = Platform.isIOS 
                          ? AppConfig.APPLESTOREURL 
                          : AppConfig.GOOGLESTOREURL;
                      
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                      
                      if (!isForceUpdate) {
                        completer(DialogResponse(confirmed: true));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}