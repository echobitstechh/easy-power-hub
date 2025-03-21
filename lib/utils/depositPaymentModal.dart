import 'package:easyph/core/data/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/data/models/profile.dart';
import '../state.dart';
import '../ui/common/app_colors.dart';
import '../ui/common/ui_helpers.dart';
import '../ui/components/submit_button.dart';
import '../ui/components/text_field_widget.dart';
import 'money_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pay/pay.dart';
import 'inAppPayConfig.dart' as payment_configurations;



class DepositsPaymentModalWidget extends StatelessWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback onProceedWithPayment;
  final PaymentMethod selectedPaymentMethod;
  final ValueNotifier<bool> isPaymentProcessing;
  final TextEditingController amountController;

  const DepositsPaymentModalWidget({
    Key? key,
    required this.onPaymentMethodSelected,
    required this.onProceedWithPayment,
    required this.selectedPaymentMethod,
    required this.isPaymentProcessing,
    required this.amountController,
  }) : super(key: key);


  void handleProceedWithPayment(BuildContext context) {
    isPaymentProcessing.value = true;

    // Simulate payment process delay
    Future.delayed(const Duration(seconds: 2), () {
      isPaymentProcessing.value = false;
      _showSuccessDialog(context);
    });
  }


  @override
  Widget build(BuildContext context) {


    return ValueListenableBuilder<Profile?>(
        valueListenable: profile,
        builder: (context, profileData, _) {
          return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25.0),
                  topLeft: Radius.circular(25.0),
                ),
              ),
              child:

      SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // This adds padding equal to the height of the keyboard when it's open
        ),
        child: Container(
          // padding: const EdgeInsets.all(16.0),
          decoration:  BoxDecoration(
            color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0),
              topLeft: Radius.circular(25.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: kcPrimaryColor, // Yellowish background
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    topLeft: Radius.circular(25.0),
                  ), // Adjusted border-radius only for the top
                ),
                child: Text(
                  "Deposit into wallet",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bricolageGrotesque(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
          
              // Enter Amount Section
              _buildTotalSection(amountController),
          
              const SizedBox(height: 10),
          
              if(selectedPaymentMethod == PaymentMethod.wallet)
                Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Current Balance:₦0}",
         // ${profile.value.accountPointsLocal ??
          style: TextStyle(
                      color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                      fontSize: 12,
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          
              const SizedBox(height: 20),

              // Payment Method Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Method",
                      style: GoogleFonts.redHatDisplay(
                        textStyle:  TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildPaymentMethodOption(
                        context,
                        paymentMethodIcon: "flutter_wave",
                        method: PaymentMethod.flutterwave,
                        selectedMethod: selectedPaymentMethod,
                        onTap: () => onPaymentMethodSelected(PaymentMethod.flutterwave),
                      ),
                    ),
                    horizontalSpaceSmall,
                    Expanded(child: _buildPaymentMethodOption(
                      context,
                      paymentMethodIcon: "paystack",
                      method: PaymentMethod.paystack,
                      selectedMethod: selectedPaymentMethod,
                      onTap: () => onPaymentMethodSelected(PaymentMethod.paystack),
                    ),)

                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Proceed Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isPaymentProcessing, // Listen to the notifier
                    builder: (context, isLoading, child) {
                      return SubmitButton(
                        isLoading: isLoading, // Reflect loading state
                        label: "Proceed",
                        submit: () => handleProceedWithPayment(context),
                        color: kcPrimaryColor,
                      );
                    },
                  ),
                ),
          
              verticalSpaceSmall
            ],
          ),
        ),
      ),
      ));});


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
          color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcVeryLightGrey,
          border: Border.all(
            color: isSelected ?  kcSecondaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/icons/$paymentMethodIcon.svg',
        ),
      ),
    );
  }

  Widget _buildTotalSection(TextEditingController totalAmount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Amount",
            style: GoogleFonts.redHatDisplay(
              textStyle:  TextStyle(
                color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: totalAmount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "amount",
              hintStyle:  TextStyle(
                color: uiMode.value == AppUiModes.dark ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: uiMode.value == AppUiModes.dark ? Colors.grey[500] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context), // Close the dialog
                  child: const Icon(
                    Icons.cancel,
                    size: 24,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/images/rafflesDollar.svg', // Replace with your success image path
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                "🎉Deposit Successful!🎉",
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Thank you for your deposit! Your funds have been successfully added to your account😉",
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

}

