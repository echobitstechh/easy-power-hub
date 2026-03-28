import 'package:easy_ph/core/data/models/installment.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';

class InstallmentPaymentSheet extends StatefulWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const InstallmentPaymentSheet({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  State<InstallmentPaymentSheet> createState() => _InstallmentPaymentSheetState();
}

class _InstallmentPaymentSheetState extends State<InstallmentPaymentSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final plan = widget.request.data as InstallmentPlan?;
    final currencyFormat = NumberFormat('#,###.##');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDarkMode ? kcDarkGreyColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Installment Payment",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kcOrangeColor,
                ),
              ),
              IconButton(
                onPressed: () => widget.completer(SheetResponse(confirmed: false)),
                icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
          verticalSpaceMedium,
          _buildInfoRow(context, "Item", plan?.product.productName ?? 'N/A'),
          verticalSpaceTiny,
          _buildInfoRow(
              context, "Total Amount", "₦${currencyFormat.format(plan?.goalAmount ?? 0)}"),
          verticalSpaceTiny,
          _buildInfoRow(
              context, "Balance", "₦${currencyFormat.format(plan?.balance ?? 0)}"),
          verticalSpaceMedium,
          Text(
            "Payment Amount", 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          verticalSpaceSmall,
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter amount",
              hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
              filled: true,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixText: "₦ ",
              prefixStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          verticalSpaceLarge,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      widget.completer(SheetResponse(confirmed: false)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
              horizontalSpaceMedium,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_amountController.text.isEmpty) return;
                    widget.completer(SheetResponse(
                      confirmed: true,
                      data: double.tryParse(_amountController.text) ?? 0.0,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcOrangeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Proceed",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
