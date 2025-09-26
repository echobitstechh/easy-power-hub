import 'package:easy_ph/core/utils/money_util.dart';

import '../../../core/data/models/service.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../services_viewmodel.dart';

class ServiceItem extends StatelessWidget {
  final Service service;
  final ServicesviewModel viewModel;

  const ServiceItem({
    Key? key,
    required this.service,
    required this.viewModel,
  }) : super(key: key);

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
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: service.image ?? 'https://via.placeholder.com/120', // Fallback for null image
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
            // Service Details
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  Text(
                    MoneyUtils().formatAmount(service.price.toInt()),
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpaceSmall,
            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: () => viewModel.openWhatsAppChat(
                    service.name,
                    service.phoneNumber ?? '',
                  ),
                ),
                verticalSpaceTiny,
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blueAccent), // Changed color for distinction
                  onPressed: () => viewModel.callNumber(
                    service.phoneNumber ?? '',
                  ),
                ),
                verticalSpaceSmall,
                // Example of a button to show the address sheet, if applicable per service
                // This assumes `showServiceAddressSheet` can be generic or adapted.
                // You might need to pass the current service to the sheet as well.
                // TextButton(
                //   onPressed: () => viewModel.showServiceAddressSheet(context, service),
                //   child: const Text('Order Service'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}