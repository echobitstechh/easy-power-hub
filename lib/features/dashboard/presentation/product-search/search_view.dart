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
import '../../../../ui/components/shimmers/search_shimmer.dart';

class SearchView extends StackedView<DashboardViewModel> {
  const SearchView({Key? key}) : super(key: key);

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
      return _buildEmptyState(isDark);
    }
    if (viewModel.isLoadingSearch) {
      return SearchShimmer(isDarkMode: isDark);
    }
    if (viewModel.isSearching && viewModel.searchResults.isEmpty) {
      return _buildNoResults(viewModel, isDark);
    }
    return _buildSearchResults(context, viewModel, isDark);
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            '${viewModel.searchResults.length} '
            '${viewModel.searchResults.length == 1 ? 'product' : 'products'} found',
            style: TextStyle(fontFamily: 'HostGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.searchResults.length,
            itemBuilder: (ctx, i) => _SearchResultItem(
              product: viewModel.searchResults[i],
              viewModel: viewModel,
              isDark: isDark,
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
  bool get reactive => true;
}

// â”€â”€ Glass search app bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GlassSearchAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final DashboardViewModel viewModel;
  final bool isDark;
  const _GlassSearchAppBar({
    required this.viewModel,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_GlassSearchAppBar> createState() => _GlassSearchAppBarState();
}

class _GlassSearchAppBarState extends State<_GlassSearchAppBar> {
  final TextEditingController _controller = TextEditingController();
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
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

