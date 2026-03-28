import 'package:easy_ph/core/data/models/wallet_transaction.dart';
import 'package:easy_ph/features/wallet/wallet_viewmodel.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:easy_ph/ui/components/shimmers/wallet_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class WalletView extends StackedView<WalletViewModel> {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, WalletViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: viewModel.goBack,
        ),
        title: const Text(
          "My Wallet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: viewModel.isBusy
          ? const WalletShimmer()
          : RefreshIndicator(
              onRefresh: viewModel.init,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpaceSmall,
                    _buildBalanceCard(context, viewModel),
                    verticalSpaceMedium,
                    _buildHistoryHeader(context, viewModel),
                    verticalSpaceSmall,
                    Expanded(
                      child: _buildTransactionList(viewModel),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kcOrangeDarkColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 20),
              horizontalSpaceTiny,
              const Text(
                "Total Balance",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.isBalanceVisible
                    ? "₦${NumberFormat('#,###').format(viewModel.totalBalance)}"
                    : "₦******",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              horizontalSpaceSmall,
              IconButton(
                icon: Icon(
                  viewModel.isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white,
                ),
                onPressed: viewModel.toggleBalanceVisibility,
              ),
            ],
          ),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  "Savings",
                  Colors.white,
                  kcOrangeColor,
                  viewModel.navigateToSavings,
                ),
              ),
              horizontalSpaceMedium,
              Expanded(
                child: _buildActionButton(
                  context,
                  "Installments",
                  Colors.white,
                  kcDarkGreyColor,
                  viewModel.navigateToInstallments,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context, WalletViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterOptions(context, viewModel),
        ),
      ],
    );
  }

  void _showFilterOptions(BuildContext context, WalletViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              verticalSpaceMedium,
              _filterTile(context, "All", viewModel),
              _filterTile(context, "Savings", viewModel),
              _filterTile(context, "Installments", viewModel),
              _filterTile(context, "Successful", viewModel),
              _filterTile(context, "Failed", viewModel),
              _filterTile(context, "Processing", viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _filterTile(
      BuildContext context, String filter, WalletViewModel viewModel) {
    final isSelected = viewModel.currentFilter == filter;
    return ListTile(
      title: Text(filter),
      trailing:
          isSelected ? const Icon(Icons.check, color: kcPrimaryColor) : null,
      onTap: () {
        viewModel.filterTransactions(filter);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTransactionList(WalletViewModel viewModel) {
    if (viewModel.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: viewModel.transactions.length,
      separatorBuilder: (context, index) => verticalSpaceSmall,
      itemBuilder: (context, index) {
        final transaction = viewModel.transactions[index];
        return _buildTransactionCard(context, transaction);
      },
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, WalletTransaction transaction) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateFormat formatter = DateFormat('MMMM d, yyyy, h:mm a');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.refNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    horizontalSpaceSmall,
                    _buildTypeBadge(transaction.typeLabel, isDarkMode),
                  ],
                ),
                Text(
                  "${transaction.currency}${NumberFormat('#,###').format(transaction.amount)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : kcBlackColor,
                  ),
                ),
              ],
            ),
            verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatter.format(transaction.dateTime),
                  style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13),
                ),
                Text(
                  transaction.statusLabel,
                  style: TextStyle(
                    color: transaction.statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isDarkMode ? Colors.grey[400] : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kcOrangeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: kcOrangeColor,
            ),
          ),
          verticalSpaceMedium,
          const Text(
            "No Transactions Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceSmall,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your transaction history will appear here once you start using your wallet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          verticalSpaceLarge,
        ],
      ),
    );
  }

  @override
  void onViewModelReady(WalletViewModel viewModel) {
    viewModel.init();
  }

  @override
  WalletViewModel viewModelBuilder(BuildContext context) => WalletViewModel();
}
