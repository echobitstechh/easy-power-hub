import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/data/models/profile.dart';
import '../state.dart';
import '../ui/common/app_colors.dart';
import '../ui/common/ui_helpers.dart';
import '../ui/components/submit_button.dart';



class DonationsPaymentModalWidget extends StatelessWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback onProceedWithPayment;
  final PaymentMethod selectedPaymentMethod;
  final ValueNotifier<bool> isPaymentProcessing;
  final TextEditingController amountController;

  const DonationsPaymentModalWidget({
    Key? key,
    required this.onPaymentMethodSelected,
    required this.onProceedWithPayment,
    required this.selectedPaymentMethod,
    required this.isPaymentProcessing,
    required this.amountController,
  }) : super(key: key);

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
            borderRadius: const BorderRadius.only(
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
                decoration: const BoxDecoration(
                  color: kcSecondaryColor, // Yellowish background
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    topLeft: Radius.circular(25.0),
                  ), // Adjusted border-radius only for the top
                ),
                child: Text(
                  "Donate to this Project",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPaymentMethodOption(
                    context,
                    paymentMethodIcon: "wallet",
                    method: PaymentMethod.wallet,
                    selectedMethod: selectedPaymentMethod,
                    onTap: () => onPaymentMethodSelected(PaymentMethod.wallet),
                  ),
                  _buildPaymentMethodOption(
                    context,
                    paymentMethodIcon: "flutter_wave",
                    method: PaymentMethod.flutterwave,
                    selectedMethod: selectedPaymentMethod,
                    onTap: () => onPaymentMethodSelected(PaymentMethod.flutterwave),
                  ),
                  _buildPaymentMethodOption(
                    context,
                    paymentMethodIcon: "paystack",
                    method: PaymentMethod.paystack,
                    selectedMethod: selectedPaymentMethod,
                    onTap: () => onPaymentMethodSelected(PaymentMethod.paystack),
                  ),
                ],
              ),
          
              const SizedBox(height: 20),
          
              // Enter Amount Section
              _buildTotalSection(amountController),
          
              const SizedBox(height: 10),
          
              if(selectedPaymentMethod == PaymentMethod.wallet)
              //   Align(
              //   alignment: Alignment.centerRight,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: Text(
              //       "Available Balance: ${profileData?.accountPoints} points",
              //       style: TextStyle(
              //         color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
              //         fontSize: 12,
              //         fontFamily: 'roboto',
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),
              // ),
          
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
                        submit: onProceedWithPayment,
                        color: kcSecondaryColor,
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
          height: 40,
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
            selectedPaymentMethod == PaymentMethod.wallet ? "Enter Point" : "Enter Amount",
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
              hintText: selectedPaymentMethod == PaymentMethod.wallet ? "point" : "amount",
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
}

