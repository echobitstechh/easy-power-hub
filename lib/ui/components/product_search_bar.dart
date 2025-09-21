
import 'package:flutter/material.dart';
import '../../core/data/models/product.dart';
import '../../features/dashboard/presentation/dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/widgets/product_card.dart';
import '../../state.dart';
import '../common/app_colors.dart';


class ProductSearchBar extends StatelessWidget {
  final DashboardViewModel viewModel;

  const ProductSearchBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Autocomplete<Product>(
        optionsBuilder: (TextEditingValue productTextEditingValue) {
          if (productTextEditingValue.text.isEmpty) {
            return const Iterable<Product>.empty();
          }
          final query = productTextEditingValue.text.toLowerCase();
          return viewModel.filteredProductList.where((Product product) {
            return (product.productName?.toLowerCase().contains(query) ?? false) ||
                (product.brandName?.toLowerCase().contains(query) ?? false);
          });
        },
        displayStringForOption: (Product product) => product.productName ?? '',
        onSelected: (Product value) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)),
            ),
            backgroundColor: Colors.black.withOpacity(0.7),
            builder: (BuildContext context) {
              return ProductCard(product: value);
            },
          );
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return Container(
            height: 40,
            decoration: BoxDecoration(
              color: uiMode.value == AppUiModes.dark ? kcMediumGrey : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey, // The fix
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Search product...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<Product> onSelected,
            Iterable<Product> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 250,
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Product product = options.elementAt(index);
                    return ListTile(
                      leading: (product.images != null && product.images!.isNotEmpty)
                          ? Image.network(
                        product.images!.first,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image, size: 30),
                      title: Text(
                        product.productName ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                      onTap: () => onSelected(product),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}