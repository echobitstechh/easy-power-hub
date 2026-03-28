import 'package:easy_ph/core/data/models/savings.dart';
import 'package:easy_ph/features/wallet/savings/savings_details_viewmodel.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class SavingsDetailsView extends StackedView<SavingsDetailsViewModel> {
  final SavingsPlan plan;
  const SavingsDetailsView({Key? key, required this.plan}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, SavingsDetailsViewModel viewModel, Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: viewModel.goBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    plan.product.images?.first ??
                        'https://via.placeholder.com/400x250',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.product.productName ?? 'Item Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        verticalSpaceTiny,
                        _buildStatusBadge(plan),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(plan, currencyFormat, isDarkMode),
                  verticalSpaceLarge,
                  const Text(
                    "Payment Timeline",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  verticalSpaceMedium,
                  _buildTimeline(plan, isDarkMode),
                  verticalSpaceLarge,
                  if (!plan.isCompleted)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                viewModel.showPaymentOverlay(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kcOrangeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Make Payment",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        verticalSpaceMedium,
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: viewModel.moveToCheckout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kcOrangeColor,
                              side: const BorderSide(
                                  color: kcOrangeColor, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Move to Checkout",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  verticalSpaceLarge,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SavingsPlan plan) {
    final color = plan.isCompleted ? Colors.green : Colors.grey[400];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        plan.statusLabel,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatsSection(
      SavingsPlan plan, NumberFormat format, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? kcDarkGreyColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
              "Goal", "₦${format.format(plan.goalAmount)}", isDarkMode),
          verticalSpaceMedium,
          _buildStatRow(
              "Balance", "₦${format.format(plan.balance)}", isDarkMode,
              isBold: true),
          verticalSpaceMedium,
          _buildProgressCircle(plan),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDarkMode,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold
                ? kcOrangeColor
                : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle(SavingsPlan plan) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: plan.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    plan.isCompleted ? Colors.green : kcOrangeColor),
                strokeWidth: 8,
              ),
              Center(
                child: Text(
                  "${plan.progressPercent}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        verticalSpaceSmall,
        Text(
          "Progress",
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTimeline(SavingsPlan plan, bool isDarkMode) {
    if (plan.payments.isEmpty) {
      return const Center(child: Text("No payments yet"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plan.payments.length,
      itemBuilder: (context, index) {
        final payment = plan.payments[index];
        final isLast = index == plan.payments.length - 1;
        final dateFormat = DateFormat('MMMM d, yyyy');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: kcOrangeColor, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 14, color: kcOrangeColor),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey[300],
                  ),
              ],
            ),
            horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(payment.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      _buildPaidBadge(),
                    ],
                  ),
                  Text(dateFormat.format(payment.date),
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  Text("₦${NumberFormat('#,###').format(payment.amount)}",
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  verticalSpaceMedium,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaidBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text("Paid",
          style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  @override
  void onViewModelReady(SavingsDetailsViewModel viewModel) {
    viewModel.init(plan);
  }

  @override
  SavingsDetailsViewModel viewModelBuilder(BuildContext context) =>
      SavingsDetailsViewModel();
}
