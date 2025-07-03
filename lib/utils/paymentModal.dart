import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../state.dart';
import '../ui/common/app_colors.dart';
import '../ui/common/ui_helpers.dart';
import 'money_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pay/pay.dart';
import 'inAppPayConfig.dart' as payment_configurations;



class PaymentModalWidget extends StatelessWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback onProceedWithPayment;
  final int totalAmount;
  final PaymentMethod selectedPaymentMethod;
  final bool isPaymentProcessing;

  const PaymentModalWidget({
    Key? key,
    required this.onPaymentMethodSelected,
    required this.onProceedWithPayment,
    required this.totalAmount,
    required this.selectedPaymentMethod,
    required this.isPaymentProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define your modal UI here
    final List<PaymentItem> _paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: totalAmount.toString(),
        status: PaymentItemStatus.final_price,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: kcSecondaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25.0),
          topLeft: Radius.circular(25.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allow content to determine height
          children: [
            const Text(
              "Choose Payment Method",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: kcPrimaryColor,
                fontFamily: "Panchang",
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 0.0, // Space between the chips
              runSpacing: 2.0, // Space between the rows
              children: [
                _buildPaymentMethodOption(
                  context,
                  paymentMethodIcon: "paystack",
                  method: PaymentMethod.paystack,
                  selectedMethod: selectedPaymentMethod,
                  onTap: () => onPaymentMethodSelected(PaymentMethod.paystack),
                ),
                _buildPaymentMethodOption(
                  context,
                  paymentMethodIcon: "flutter_wave",
                  method: PaymentMethod.flutterwave,
                  selectedMethod: selectedPaymentMethod,
                  onTap: () => onPaymentMethodSelected(PaymentMethod.flutterwave),
                ),
                _buildApplePayOption(context, _paymentItems),
              ],
            ),
            verticalSpaceMedium,
            const Divider(color: Colors.white54),
            _buildTotalSection(totalAmount),
            verticalSpaceMedium,
            if (isPaymentProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: onProceedWithPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor, // Button color
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/pay.svg',
                      height: 20, // Icon size
                    ),
                    horizontalSpaceSmall,
                    Text(
                      "Pay ₦${totalAmount.toStringAsFixed(2)}", // Adjust text format as needed
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kcWhiteColor,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      BuildContext context, {
        required String paymentMethodIcon,
        required PaymentMethod method,
        required PaymentMethod selectedMethod,
        required VoidCallback onTap,
      }) {
    bool isSelected = selectedMethod == method;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? kcPrimaryColor : Colors.transparent,
            width: 5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          'assets/icons/$paymentMethodIcon.svg',
          height: 50,
        ),
      ),
    );
  }

  Widget _buildApplePayOption(BuildContext context, List<PaymentItem> _paymentItems) {
    return ApplePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        payment_configurations.defaultApplePay,
      ),
      paymentItems: _paymentItems,
      style: ApplePayButtonStyle.black,
      type: ApplePayButtonType.buy,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: onApplePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void onApplePayResult(paymentResult) {
    // Send the resulting Apple Pay token to your server / PSP
  }

  Widget _buildTotalSection(int totalAmount) {
    return Column(
      children: [
        _buildTotalLineItem(
          label: "Total Amount",
          amount: MoneyUtils().formatAmount(totalAmount),
        ),
      ],
    );
  }

  Widget _buildTotalLineItem({required String label, required String amount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Roboto',),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

