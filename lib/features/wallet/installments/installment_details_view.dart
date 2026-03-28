import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ph/core/data/models/installment.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'installment_details_viewmodel.dart';

class InstallmentDetailsView extends StackedView<InstallmentDetailsViewModel> {
  final InstallmentPlan plan;

  const InstallmentDetailsView({Key? key, required this.plan})
      : super(key: key);

  @override
  Widget builder(BuildContext context, InstallmentDetailsViewModel viewModel,
      Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###.##');

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.plan.product.productName ?? 'Unknown Product',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: viewModel.plan.product.images?.first ?? '',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              verticalSpaceMedium,
              const Text("Progress", style: TextStyle(color: Colors.grey)),
              verticalSpaceSmall,
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: CircularProgressIndicator(
                        value: viewModel.plan.progress,
                        strokeWidth: 12,
                        backgroundColor: kcOrangeColor.withOpacity(0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(kcOrangeColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${viewModel.plan.progressPercent}%",
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Text("Complete",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              verticalSpaceMedium,
              _buildMetricRow(
                  "Amount",
                  "₦${currencyFormat.format(viewModel.plan.goalAmount)}",
                  isDarkMode),
              verticalSpaceSmall,
              _buildMetricRow(
                  "Paid So Far",
                  "₦${currencyFormat.format(viewModel.plan.totalPaid)}",
                  isDarkMode),
              verticalSpaceSmall,
              _buildMetricRow(
                  "Remaining",
                  "₦${currencyFormat.format(viewModel.plan.balance)}",
                  isDarkMode),
              verticalSpaceMedium,
              if (!viewModel.plan.isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => viewModel.showPaymentOverlay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcOrangeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Make Next Payment",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              verticalSpaceLarge,
              const Text(
                "Payment Timeline",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              _buildPaymentTimeline(context, viewModel),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildPaymentTimeline(
      BuildContext context, InstallmentDetailsViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.plan.payments.length,
      itemBuilder: (context, index) {
        final payment = viewModel.plan.payments[index];
        return _buildTimelineItem(
            context, payment, index == viewModel.plan.payments.length - 1);
      },
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, InstallmentPayment payment, bool isLast) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat('#,###.##');
    final dateFormat = DateFormat('MMMM d, yyyy');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: payment.isPaid
                      ? kcOrangeColor.withOpacity(0.1)
                      : (payment.isDue
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1)),
                  border: Border.all(
                    color: payment.isPaid
                        ? kcOrangeColor
                        : (payment.isDue ? Colors.red : Colors.grey),
                  ),
                ),
                child: Icon(
                  payment.isPaid
                      ? Icons.check
                      : (payment.isDue ? Icons.close : null),
                  size: 14,
                  color: payment.isPaid
                      ? kcOrangeColor
                      : (payment.isDue ? Colors.red : Colors.transparent),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: payment.isPaid ? kcOrangeColor : Colors.grey[300],
                  ),
                ),
            ],
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dateFormat.format(payment.date),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: payment.isPaid
                              ? Colors.black
                              : (payment.isDue ? Colors.red : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.isPaid
                              ? "Paid"
                              : (payment.isDue ? "Due" : "Upcoming"),
                          style: TextStyle(
                            color: payment.isPaid || payment.isDue
                                ? Colors.white
                                : Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      Text(
                        "₦${currencyFormat.format(payment.amount)}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  InstallmentDetailsViewModel viewModelBuilder(BuildContext context) =>
      InstallmentDetailsViewModel();

  @override
  void onViewModelReady(InstallmentDetailsViewModel viewModel) =>
      viewModel.init(plan);
}
