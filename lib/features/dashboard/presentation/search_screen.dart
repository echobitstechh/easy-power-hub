import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/models/product.dart';
import '../../../ui/common/app_colors.dart';
import './dashboard_viewmodel.dart';
import './product_details/product_card.dart';

class SearchScreen extends StatefulWidget {
  final DashboardViewModel viewModel;

  const SearchScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    setState(() {
      _searchQuery = query.toLowerCase();
      
      if (_searchQuery.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        _isLoading = false;
        _debounceTimer?.cancel();
      } else {
        _isSearching = true;
        _isLoading = true;
        _debounceTimer?.cancel();

        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          _performSearch(query);
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    final results = await widget.viewModel.searchProducts(query);
    
    if (_searchController.text.trim() == query) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _searchQuery = '';
    });
    _focusNode.requestFocus();
  }

  void _showProductDetails(Product product) {
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
      // backgroundColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return ProductCard(
          product: product,
          dashboardViewModel: widget.viewModel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Container(
            height: 45,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(
                color: isDarkMode ? kcWhiteColor : kcBlackColor,
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
                suffixIcon: _searchQuery.isNotEmpty
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
          ),
        ),
        body: _buildBody(isDarkMode),
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_searchQuery.isEmpty && !_isSearching) {
      return _buildEmptyState(isDarkMode);
    }

    if (_isLoading) {
      return _buildSearchShimmer(isDarkMode);
    }

    if (_isSearching && _searchResults.isEmpty) {
      return _buildNoResults(isDarkMode);
    }

    return _buildSearchResults(isDarkMode);
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

  Widget _buildNoResults(bool isDarkMode) {
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
                    text: '"$_searchQuery"',
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

  Widget _buildSearchResults(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${_searchResults.length} ${_searchResults.length == 1 ? 'product' : 'products'} found',
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
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              // final isOutOfStock = (product.availability ?? 0) < 1;
              
              return InkWell(
                onTap: () => _showProductDetails(product),
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
                      // Product Image
                      Stack(
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
                          // if (isOutOfStock)
                          //   Positioned.fill(
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //         color: Colors.black.withOpacity(0.5),
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //       child: const Center(
                          //         child: Text(
                          //           'Out of Stock',
                          //           style: TextStyle(
                          //             color: Colors.white,
                          //             fontSize: 9,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //           textAlign: TextAlign.center,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                        
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Product Details
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
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '₦${(double.tryParse(product.salePrice ?? '')?.toStringAsFixed(0) ?? '0')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? kcWhiteColor : kcBlackColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // if (product.availability != null && product.availability! > 0)
                                //   Container(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 6,
                                //       vertical: 2,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.green.withOpacity(0.1),
                                //       borderRadius: BorderRadius.circular(4),
                                //     ),
                                //     child: Text(
                                //       'In Stock',
                                //       style: TextStyle(
                                //         fontSize: 10,
                                //         fontWeight: FontWeight.w600,
                                //         color: Colors.green[700],
                                //       ),
                                //     ),
                                //   ),
                              ],
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchShimmer(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : kcWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _shimmerEffect(isDarkMode),
              ),
              const SizedBox(width: 12),
              // Text shimmers
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name shimmer
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _shimmerEffect(isDarkMode),
                    ),
                    const SizedBox(height: 8),
                    // Brand name shimmer
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _shimmerEffect(isDarkMode),
                    ),
                    const SizedBox(height: 8),
                    // Price shimmer
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _shimmerEffect(isDarkMode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerEffect(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!)
                      .withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation
        setState(() {});
      },
    );
  }

}