import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../../core/data/models/product.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../dashboard_viewmodel.dart';
import '../product_details/product_card.dart';
import '../widgets/product_grid_item.dart';
import '../../../../ui/components/shimmers/search_shimmer.dart';

class SearchView extends StackedView<DashboardViewModel> {
  SearchView({Key? key}) : super(key: key);

  final TextEditingController searchController = TextEditingController();
  final ScrollController _resultsController = ScrollController();

  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _GlassSearchAppBar(
            controller: searchController,
            viewModel: viewModel,
            isDark: isDark,
          ),
          body: _buildBody(context, viewModel, isDark),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardViewModel viewModel,
    bool isDark,
  ) {
    if (viewModel.searchQuery.isEmpty && !viewModel.isSearching) {
      return _buildEmptyState(viewModel, isDark);
    }
    if (viewModel.isLoadingSearch) {
      return SearchShimmer(isDarkMode: isDark);
    }
    if (viewModel.isSearching && viewModel.searchResults.isEmpty) {
      return _buildNoResults(viewModel, isDark);
    }
    return _buildSearchResults(context, viewModel, isDark);
  }

  Widget _buildEmptyState(DashboardViewModel viewModel, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          if (viewModel.recentSearches.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Searches',
                style: TextStyle(fontFamily: 'HostGrotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? kcWhiteColor : kcBlackColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: viewModel.recentSearches.map((term) {
                return _RecentSearchChip(
                  label: term,
                  isDark: isDark,
                  onTap: () => searchController.text = term,
                  onRemove: () => viewModel.removeRecentSearch(term),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          Icon(Icons.search_rounded, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for products',
            style: TextStyle(fontFamily: 'HostGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? kcWhiteColor : kcBlackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find products by name, brand or category',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(DashboardViewModel viewModel, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded,
                size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontFamily: 'HostGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? kcWhiteColor : kcBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                children: [
                  const TextSpan(text: 'No match for '),
                  TextSpan(
                    text: '"${viewModel.searchQuery}"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? kcWhiteColor : kcBlackColor,
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

  Widget _buildSearchResults(
    BuildContext context,
    DashboardViewModel viewModel,
    bool isDark,
  ) {
    final results = viewModel.searchResults;
    final related = viewModel.relatedSearchResults;
    final extraItems =
        (viewModel.isLoadingMoreSearch ? 1 : 0) + (related.isNotEmpty ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            '${results.length}${viewModel.hasMoreSearchResults ? '+' : ''} '
            '${results.length == 1 ? 'product' : 'products'} found',
            style: TextStyle(fontFamily: 'HostGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                viewModel.loadMoreSearchResults();
              }
              return false;
            },
            child: ListView.builder(
              controller: _resultsController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length + extraItems,
              itemBuilder: (ctx, i) {
                if (i < results.length) {
                  return _SearchResultItem(
                    product: results[i],
                    viewModel: viewModel,
                    isDark: isDark,
                  );
                }
                var idx = i - results.length;
                if (viewModel.isLoadingMoreSearch) {
                  if (idx == 0) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  idx -= 1;
                }
                return _RelatedProductsSection(
                  products: related,
                  viewModel: viewModel,
                  isDark: isDark,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    viewModel.loadRecentSearches();
  }

  @override
  void onDispose(DashboardViewModel viewModel) {
    searchController.dispose();
    _resultsController.dispose();
  }

  @override
  bool get reactive => true;
}

// â”€â”€ Glass search app bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GlassSearchAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;
  final DashboardViewModel viewModel;
  final bool isDark;
  const _GlassSearchAppBar({
    required this.controller,
    required this.viewModel,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_GlassSearchAppBar> createState() => _GlassSearchAppBarState();
}

class _GlassSearchAppBarState extends State<_GlassSearchAppBar> {
  TextEditingController get _controller => widget.controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {}); // refresh the clear-icon visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.viewModel.performSearch(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: widget.isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () {
                    widget.viewModel.clearSearch();
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isDark
                            ? kcGlassBorderDark
                            : kcGlassBorderLight,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: widget.isDark ? kcWhiteColor : kcBlackColor,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(fontFamily: 'HostGrotesk',
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.grey[500], size: 20),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: Colors.grey[500], size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  widget.viewModel.clearSearch();
                                  _focusNode.requestFocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Search result item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SearchResultItem extends StatelessWidget {
  final Product product;
  final DashboardViewModel viewModel;
  final bool isDark;

  const _SearchResultItem({
    required this.product,
    required this.viewModel,
    required this.isDark,
  });

  void _openProduct(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProductCard(product: product, dashboardViewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openProduct(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (product.images?.isNotEmpty == true)
                      ? Image.network(
                          product.images!.first,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 68,
                            height: 68,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_rounded,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 68,
                          height: 68,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_rounded,
                              color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName ?? 'Unknown Product',
                        style: TextStyle(fontFamily: 'HostGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? kcWhiteColor : kcBlackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.brandName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          product.brandName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      if (product.tags?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: product.tags!.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: kcSecondaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kcSecondaryColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        MoneyUtils().formatAmount(
                          (double.tryParse(product.salePrice ?? '0') ?? 0).toInt(),
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kcSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent search chip ───────────────────────────────────────────────────

class _RecentSearchChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchChip({
    required this.label,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? kcWhiteColor : kcBlackColor,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 15, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── You may also like ────────────────────────────────────────────────────

class _RelatedProductsSection extends StatelessWidget {
  final List<Product> products;
  final DashboardViewModel viewModel;
  final bool isDark;

  const _RelatedProductsSection({
    required this.products,
    required this.viewModel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You may also like',
            style: TextStyle(fontFamily: 'HostGrotesk',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? kcWhiteColor : kcBlackColor,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) => SizedBox(
                width: 150,
                child: ProductGridItem(
                  product: products[i],
                  viewModel: viewModel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

