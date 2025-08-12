import 'package:cached_network_image/cached_network_image.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/data/models/tags.dart';
import '../common/app_colors.dart';
import '../views/dashboard/dashboard_viewmodel.dart';

Widget buildProductTagsSection(
    BuildContext context,
    DashboardViewModel viewModel, {
      Key? sectionKey,
      VoidCallback? onAnyTagTap,
    }

    ) {
  if (viewModel.isLoadingTags) {
    return buildTagsShimmerLoading(false);
  }

  if (viewModel.hasTagsError) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            viewModel.tagsError ?? 'Error loading tags',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => viewModel.refreshTags(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (viewModel.tags.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    key: sectionKey,
    height: 160,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: viewModel.tags.length,
      itemBuilder: (context, index) {
        final tag = viewModel.tags[index];
        return _buildTagChip(context, tag, viewModel, onAnyTagTap: onAnyTagTap);
      },
    ),
  );
}

Widget _buildTagChip(
    BuildContext context,
    Tag tag,
    DashboardViewModel viewModel, {
      VoidCallback? onAnyTagTap,         // NEW
    }
    ) {
  final isSelected = viewModel.selectedTag?.id == tag.id;

  return InkWell(
    onTap: () {
      onAnyTagTap?.call();
      viewModel.setSelectedTag(isSelected ? null : tag);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: (tag.image != null && tag.image!.isNotEmpty)
                  ? DecorationImage(
                image: CachedNetworkImageProvider(tag.image!),
                fit: BoxFit.cover,
              )
                  : null,
              color: (tag.image == null || tag.image!.isEmpty)
                  ? Colors.grey[200]
                  : null,
            ),
            child: (tag.image == null || tag.image!.isEmpty)
                ? const Center(child: Icon(Icons.category, size: 28))
                : null,
          ),
         horizontalSpaceTiny,
          Text(
            tag.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? kcSecondaryColor : null,
            ),
          ),
        ],
      ),
    ),
  );
}
