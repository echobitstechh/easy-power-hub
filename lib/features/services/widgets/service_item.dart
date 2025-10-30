
import '../../../core/data/models/service.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state.dart';
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
                    onPressed: () => viewModel.requestSpecificService(service),
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