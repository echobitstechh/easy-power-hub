import 'package:easy_ph/core/data/models/savings.dart';
import 'package:easy_ph/features/wallet/savings/my_savings_viewmodel.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:easy_ph/ui/components/shimmers/savings_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class MySavingsView extends StackedView<MySavingsViewModel> {
  const MySavingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, MySavingsViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: viewModel.goBack,
        ),
        title: const Text(
          "My Savings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: viewModel.isBusy
          ? const SavingsShimmer()
          : viewModel.savingsPlans.isEmpty
              ? _buildEmptyState(context, viewModel)
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      ...viewModel.savingsPlans
                          .map((plan) =>
                              _buildSavingsCard(context, plan, viewModel))
                          .toList(),
                      verticalSpaceMedium,
                      _buildCreateNewButton(context, viewModel),
                      verticalSpaceLarge,
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MySavingsViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                Icons.savings_outlined,
                size: 64,
                color: kcOrangeColor,
              ),
            ),
            verticalSpaceMedium,
            Text(
              "No Savings Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            verticalSpaceSmall,
            Text(
              "Start saving for your favorite items today and pay at your own pace.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            verticalSpaceLarge,
            _buildCreateNewButton(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(
      BuildContext context, SavingsPlan plan, MySavingsViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###.##');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? kcDarkGreyColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.product.productName ?? 'Unnamed Item',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          verticalSpaceTiny,
          _buildStatusBadge(plan),
          verticalSpaceMedium,
          _buildAmountRow("Goal", "₦${currencyFormat.format(plan.goalAmount)}"),
          verticalSpaceSmall,
          _buildAmountRow(
              "Total Paid", "-₦${currencyFormat.format(plan.totalPaid)}"),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Balance",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                "₦${currencyFormat.format(plan.balance)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          verticalSpaceMedium,
          _buildProgressBar(plan),
          verticalSpaceMedium,
          _buildCardActionButton(context, plan, viewModel),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SavingsPlan plan) {
    Color? color;
    if (plan.isCancelled) {
      color = Colors.red;
    } else if (plan.isCompleted) {
      color = Colors.green;
    } else {
      color = Colors.grey[400];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        plan.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProgressBar(SavingsPlan plan) {
    Color color;
    if (plan.isCancelled) {
      color = Colors.red.withOpacity(0.3);
    } else if (plan.isCompleted) {
      color = Colors.green;
    } else {
      color = const Color(0xFF0D1E3A);
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: plan.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        horizontalSpaceSmall,
        Text("${plan.progressPercent}%",
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCardActionButton(
      BuildContext context, SavingsPlan plan, MySavingsViewModel viewModel) {
    if (plan.isCancelled) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => viewModel.navigateToDetails(plan),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("View Details"),
        ),
      );
    }

    if (plan.isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => viewModel.navigateToDetails(plan),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("View Details"),
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => viewModel.navigateToDetails(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: kcOrangeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Make Next Payment"),
            ),
          ),
          verticalSpaceSmall,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () =>
                  _showCancelConfirmation(context, plan, viewModel),
              child: const Text(
                "Cancel Plan",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _showCancelConfirmation(
      BuildContext context, SavingsPlan plan, MySavingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Saving Plan"),
        content: const Text(
            "Are you sure you want to cancel this saving plan? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, Keep it"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.cancelPlan(plan.id);
            },
            child:
                const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewButton(
      BuildContext context, MySavingsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: viewModel.navigateToCreateSavings,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: kcOrangeColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Create New Savings",
          style: TextStyle(color: kcOrangeColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(MySavingsViewModel viewModel) {
    viewModel.init();
  }

  @override
  MySavingsViewModel viewModelBuilder(BuildContext context) =>
      MySavingsViewModel();
}
