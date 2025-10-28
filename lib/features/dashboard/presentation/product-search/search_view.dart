import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../../core/data/models/product.dart';
import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';
import '../product_details/product_card.dart';
import '../../../../ui/components/shimmers/search_shimmer.dart';

class SearchScreen extends StackedView<DashboardViewModel> {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? kcWhiteColor : kcBlackColor,
            ),
            onPressed: () {
              viewModel.clearSearch();
              Navigator.of(context).pop();
            },
          ),
          title: _SearchTextField(viewModel: viewModel, isDarkMode: isDarkMode),
        ),
        body: _buildBody(context, viewModel, isDarkMode),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardViewModel viewModel,
    bool isDarkMode,
  ) {
    if (viewModel.searchQuery.isEmpty && !viewModel.isSearching) {
      return _buildEmptyState(isDarkMode);
    }

    if (viewModel.isLoadingSearch) {
      return SearchShimmer(isDarkMode: isDarkMode);
    }

    if (viewModel.isSearching && viewModel.searchResults.isEmpty) {
      return _buildNoResults(viewModel, isDarkMode);
    }

    return _buildSearchResults(context, viewModel, isDarkMode);
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? kcWhiteColor : kcBlackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find products by name, brand or category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(DashboardViewModel viewModel, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? kcWhiteColor : kcBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                children: [
                  const TextSpan(text: 'No products match '),
                  TextSpan(
                    text: '"${viewModel.searchQuery}"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? kcWhiteColor : kcBlackColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
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
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${viewModel.searchResults.length} ${viewModel.searchResults.length == 1 ? 'product' : 'products'} found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: viewModel.searchResults.length,
            itemBuilder: (context, index) {
              final product = viewModel.searchResults[index];
              return _SearchResultItem(
                product: product,
                viewModel: viewModel,
                isDarkMode: isDarkMode,
              );
            },
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

class _SearchTextField extends StatefulWidget {
  final DashboardViewModel viewModel;
  final bool isDarkMode;

  const _SearchTextField({
    required this.viewModel,
    required this.isDarkMode,
  });

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.performSearch(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.viewModel.clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyle(
          color: widget.isDarkMode ? kcWhiteColor : kcBlackColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search product...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 22,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 22,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

// Search result item widget
class _SearchResultItem extends StatelessWidget {
  final Product product;
  final DashboardViewModel viewModel;
  final bool isDarkMode;

  const _SearchResultItem({
    required this.product,
    required this.viewModel,
    required this.isDarkMode,
  });

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return ProductCard(
          product: product,
          dashboardViewModel: viewModel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showProductDetails(context), 
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : kcWhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (product.images != null && product.images!.isNotEmpty)
                  ? Image.network(
                      product.images!.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 30),
                        );
                      },
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 30),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? kcWhiteColor : kcBlackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.brandName != null)
                    Text(
                      product.brandName!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (product.tags != null && product.tags!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: product.tags!.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '₦${(double.tryParse(product.salePrice ?? '')?.toStringAsFixed(0) ?? '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? kcWhiteColor : kcBlackColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}