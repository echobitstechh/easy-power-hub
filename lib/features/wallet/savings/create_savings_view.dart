import 'package:easy_ph/features/wallet/savings/create_savings_viewmodel.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../core/data/models/product.dart';

class CreateSavingsView extends StackedView<CreateSavingsViewModel> {
  const CreateSavingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, CreateSavingsViewModel viewModel, Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: isDarkMode ? kcDarkGreyColor : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: viewModel.goBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Saving Plan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Start saving today",
              style:
                  TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey),
            ),
            verticalSpaceLarge,
            const Text(
              "Item Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            GestureDetector(
              onTap: () => _showProductSelection(context, viewModel),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? kcVeryLightGrey.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        viewModel.selectedProduct?.productName ??
                            "Select a product",
                        style: TextStyle(
                          color: viewModel.selectedProduct != null
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : (isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600]),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            const Text(
              "Amount (Goal)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            TextField(
              readOnly: true,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: viewModel.goalAmount > 0
                    ? "₦${currencyFormat.format(viewModel.goalAmount)}"
                    : "₦0",
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.black87,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            verticalSpaceMedium,
            const Text(
              "First Payment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              onChanged: viewModel.setInitialPayment,
              decoration: InputDecoration(
                hintText: "Enter amount you want to pay now",
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                prefixText: "₦ ",
                prefixStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            verticalSpaceLarge,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: viewModel.goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isBusy ? null : viewModel.createPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcOrangeColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kcOrangeColor.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Make Payment",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  void _showProductSelection(
      BuildContext context, CreateSavingsViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? kcDarkGreyColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            verticalSpaceSmall,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            verticalSpaceMedium,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    "Select Product",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                onChanged: viewModel.performSearch,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: viewModel.isBusy && viewModel.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification &&
                            notification.metrics.extentAfter < 200) {
                          viewModel.fetchProducts();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        itemCount: viewModel.products.length +
                            (viewModel.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) => Divider(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200]),
                        itemBuilder: (context, index) {
                          if (index == viewModel.products.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final product = viewModel.products[index];
                          final price =
                              double.tryParse(product.price ?? '0') ?? 0.0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              product.productName ?? 'Unnamed Product',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "₦${currencyFormat.format(price)}",
                              style: TextStyle(
                                  color: kcOrangeColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              viewModel.setSelectedProduct(product);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(CreateSavingsViewModel viewModel) {
    viewModel.init();
  }

  @override
  CreateSavingsViewModel viewModelBuilder(BuildContext context) =>
      CreateSavingsViewModel();
}
