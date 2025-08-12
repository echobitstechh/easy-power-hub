import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../common/app_colors.dart';
import '../../core/data/models/tags.dart';

class TagsHorizontalList extends StatelessWidget {
  final List<Tag> tags;
  final Tag? selectedTag;
  final Function(Tag?) onTagSelected;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final double height;
  final double itemWidth;

  const TagsHorizontalList({
    Key? key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.height = 120, // Smaller height for dashboard
    this.itemWidth = 100, // Smaller width for dashboard
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading tags...'),
              ],
            ),
          ),
        ],
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  errorMessage ?? 'Error loading tags',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(width: 8),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ],
        if (tags.isNotEmpty) ...[
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Container(
                  width: itemWidth,
                  margin: const EdgeInsets.only(right: 8.0),
                  child: _buildTagChip(context, tag),
                );
              },
            ),
          ),
        ],
        if (tags.isEmpty && !isLoading && !hasError) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No product tags available',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, Tag tag) {
    final isSelected = selectedTag?.id == tag.id;
    return InkWell(
      onTap: () {
        onTagSelected(isSelected ? null : tag);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kcDarkGreyColor
                    : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: isSelected 
                    ? Border.all(color: kcSecondaryColor, width: 2) 
                    : Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: tag.image != null && tag.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: tag.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.category, size: 30),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Tag name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check_circle, color: kcSecondaryColor, size: 12),
                const SizedBox(width: 2),
              ],
              Expanded(
                child: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? kcSecondaryColor : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}