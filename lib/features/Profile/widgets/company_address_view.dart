import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';

class CompanyAddressSection extends StatelessWidget { 
  const CompanyAddressSection({super.key});

  // Method to launch Google Maps
  Future<void> _launchMaps(String query) async {
    // Standard URL launch logic remains the same
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Theme properties
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Addresses",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          verticalSpaceSmall,
          _buildAddressCard(
            context,
            'Abuja Office',
            'Suite B3 Saham plaza behind Banex plaza, Wuse 2, Abuja.',
          ),
          verticalSpaceTiny,
          _buildAddressCard(
            context,
            'Lagos Office',
            'House 35A, Lucky Garden Lekki County Lekki, Lagos State.',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, String title, String address) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      // Use theme colors for card background (scaffold background should be set elsewhere)
      color: theme.cardColor,
      elevation: isDarkMode ? 0 : 2, // Optional: reduce elevation in dark mode
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Uses primary text color from theme
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          address,
          style: TextStyle(
            // Uses subtitle text color from theme
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.directions,
            // Uses primary color or accent color
            color: theme.colorScheme.primary,
          ),
          onPressed: () => _launchMaps(address),
        ),
        onTap: () => _launchMaps(address),
      ),
    );
  }
}