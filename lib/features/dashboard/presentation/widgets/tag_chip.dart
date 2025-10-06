import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/models/tags.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const TagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40, // Adjusted height to prevent overflow
              width: 40, // Adjusted width for better visual balance
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (tag.image == null || tag.image!.isEmpty) ? Colors.grey[200] : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: tag.image != null && tag.image!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: tag.image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                )
                    : const Center(
                  child: Icon(Icons.category, size: 28),
                ),
              ),
            ),
            horizontalSpaceTiny,
            Expanded( // Use Expanded to allow the text to fill remaining space
              child: Text(
                tag.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? kcSecondaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}