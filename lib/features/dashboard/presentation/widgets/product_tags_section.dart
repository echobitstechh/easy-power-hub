import 'package:flutter/material.dart';

import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/shimmers/shimmer.dart';
import '../dashboard_viewmodel.dart';
import 'tag_chip.dart';

class ProductTagsSection extends StatelessWidget {
  final DashboardViewModel viewModel;
  final VoidCallback? onAnyTagTap;
  final int crossAxisCount;

  const ProductTagsSection({
    super.key,
    required this.viewModel,
    this.onAnyTagTap,
    this.crossAxisCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingTags) {
      return buildTagsShimmerLoading(crossAxisCount > 1);
    }

    if (viewModel.hasTagsError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 16),
            horizontalSpaceSmall,
            Expanded(
              child: Text(
                viewModel.tagsError ?? 'Error loading tags',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            horizontalSpaceSmall,
            TextButton(
              onPressed: () => viewModel.fetchProductTags(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    // Define the dimensions of a single tag chip
    const double tagChipHeight = 60.0; // Adjusted for a cleaner look
    const double tagChipWidth = 70.0;
    const double spacing = 8.0;

    // Calculate dynamic height based on the number of rows
    final double dynamicHeight = (tagChipHeight * crossAxisCount) + (spacing * (crossAxisCount - 1));

    return SizedBox(
      height: dynamicHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          // Correct aspect ratio for a horizontal grid: height of the cell / width of the cell
          childAspectRatio: tagChipHeight / tagChipWidth,
        ),
        itemCount: viewModel.tags.length,
        itemBuilder: (context, index) {
          final tag = viewModel.tags[index];
          return TagChip(
            tag: tag,
            isSelected: viewModel.selectedTag?.name == tag.name,
            onTap: () {
              onAnyTagTap?.call();
              viewModel.setSelectedTag(viewModel.selectedTag?.name == tag.name ? null : tag);
            },
          );
        },
      ),
    );
  }
}