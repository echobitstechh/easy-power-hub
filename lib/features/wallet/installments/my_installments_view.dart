import 'package:easy_ph/core/data/models/installment.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_ph/ui/components/shimmers/savings_shimmer.dart';
import 'my_installments_viewmodel.dart';

class MyInstallmentsView extends StackedView<MyInstallmentsViewModel> {
  const MyInstallmentsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, MyInstallmentsViewModel viewModel, Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: viewModel.goBack,
        ),
        title: const Text(
          "Installments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: viewModel.isBusy
          ? const SavingsShimmer()
          : Column(
              children: [
                Expanded(
                  child: viewModel.installments.isEmpty
                      ? _buildEmptyState(context)
                      : _buildInstallmentList(context, viewModel),
                ),
              ],
            ),
    );
  }


  Widget _buildInstallmentList(
      BuildContext context, MyInstallmentsViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: viewModel.installments.length,
      separatorBuilder: (context, index) => verticalSpaceMedium,
      itemBuilder: (context, index) {
        final plan = viewModel.installments[index];
        return _buildInstallmentCard(context, plan, viewModel);
      },
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentPlan plan,
      MyInstallmentsViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###.##');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? kcDarkGreyColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.product.productName ?? 'Unknown Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(plan),
              ],
            ),
            verticalSpaceMedium,
            _buildDataRow(
                "Goal", "₦${currencyFormat.format(plan.goalAmount)}", isDarkMode),
            verticalSpaceTiny,
            _buildDataRow(
                "Total Paid", "₦${currencyFormat.format(plan.totalPaid)}", isDarkMode),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Balance",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  plan.balance <= 0 ? "0" : "₦${currencyFormat.format(plan.balance)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            verticalSpaceMedium,
            _buildProgressBar(plan),
            verticalSpaceMedium,
            _buildCardActionButton(context, plan, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildStatusBadge(InstallmentPlan plan) {
    Color bgColor;
    Color textColor;

    if (plan.isCompleted) {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else {
      bgColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        plan.statusLabel,
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressBar(InstallmentPlan plan) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: plan.progress,
            minHeight: 8,
            backgroundColor: kcOrangeColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                plan.isCompleted ? Colors.green : kcOrangeColor),
          ),
        ),
        verticalSpaceTiny,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("${plan.progressPercent}%",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildCardActionButton(BuildContext context, InstallmentPlan plan,
      MyInstallmentsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => viewModel.navigateToDetails(plan),
        style: ElevatedButton.styleFrom(
          backgroundColor: plan.isCompleted ? Colors.black : kcOrangeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          plan.isCompleted ? "View Details" : "Make Next Payment",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          verticalSpaceMedium,
          const Text(
            "No installments yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          verticalSpaceSmall,
          Text(
            "Your installments will appear here when you\npurchase projects on plan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  MyInstallmentsViewModel viewModelBuilder(BuildContext context) =>
      MyInstallmentsViewModel();

  @override
  void onViewModelReady(MyInstallmentsViewModel viewModel) => viewModel.init();
}
