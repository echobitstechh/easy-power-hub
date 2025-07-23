import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/data/models/profile.dart';
import '../state.dart';
import '../ui/common/app_colors.dart';
import '../ui/common/ui_helpers.dart';
import '../ui/components/submit_button.dart';

class WithdrawalPaymentModalWidget extends StatelessWidget {
  final VoidCallback onProceedWithPayment;
  final ValueNotifier<bool> isPaymentProcessing;

  WithdrawalPaymentModalWidget({
    Key? key,
    required this.onProceedWithPayment,
    required this.isPaymentProcessing,
  }) : super(key: key);

  final accountNumber = TextEditingController();
  final accountName = TextEditingController();
  final enterAmount = TextEditingController();
  final verification = TextEditingController();


  void handleProceedWithPayment(BuildContext context) {
    isPaymentProcessing.value = true;

    // Simulate payment process delay
    Future.delayed(const Duration(seconds: 2), () {
      isPaymentProcessing.value = false;
      _showSuccessDialog(context);
    });
  }



  final List<String> banks = [
    'Select Bank',
    'Access Bank',
    'First Bank',
    'GT Bank',
    'Zenith Bank',
    'UBA',
    'Stanbic IBTC',
  ];


  final ValueNotifier<String> selectedBank = ValueNotifier<String>('Select Bank');


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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // This adds padding equal to the height of the keyboard when it's open
                  ),
                  child: Container(
                    // padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: uiMode.value == AppUiModes.dark
                          ? kcDarkGreyColor
                          : Colors.white,
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
                            color: kcPrimaryColor, // Yellowish background
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25.0),
                              topLeft: Radius.circular(25.0),
                            ), // Adjusted border-radius only for the top
                          ),
                          child: Text(
                            "Withdrawal Request",
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

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "select bank",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<String>(
                                valueListenable: selectedBank,
                                builder: (context, value, _) {
                                  return DropdownButtonFormField<String>(
                                    value: value,
                                    items: banks.map((String bank) {
                                      return DropdownMenuItem<String>(
                                        value: bank,
                                        child: Text(
                                          bank,
                                          style: GoogleFonts.redHatDisplay(
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        selectedBank.value = newValue;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                      filled: true,
                                      fillColor: uiMode.value == AppUiModes.dark
                                          ? Colors.grey[500]
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account Number",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: accountNumber,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Account Number",
                                  hintStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: uiMode.value == AppUiModes.dark
                                      ? Colors.grey[500]
                                      : Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account Name",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: accountName,
                                decoration: InputDecoration(
                                  hintText: "Account Name",
                                  hintStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: uiMode.value == AppUiModes.dark
                                      ? Colors.grey[500]
                                      : Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter Amount",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: enterAmount,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Enter Amount",
                                  hintStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: uiMode.value == AppUiModes.dark
                                      ? Colors.grey[500]
                                      : Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Current Balance: ₦0}",
         // ${profile.value.accountPointsLocal ?? "
                              style: TextStyle(
                                color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                                fontSize: 12,
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Verification",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: verification,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  hintStyle: TextStyle(
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: uiMode.value == AppUiModes.dark
                                      ? Colors.grey[500]
                                      : Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              verticalSpaceSmall,
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Send code",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        const SizedBox(height: 20),

                        // Proceed Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ValueListenableBuilder<bool>(
                            valueListenable:
                                isPaymentProcessing, // Listen to the notifier
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
              ));
        });
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
          color: uiMode.value == AppUiModes.dark
              ? kcDarkGreyColor
              : kcVeryLightGrey,
          border: Border.all(
            color: isSelected ? kcSecondaryColor : Colors.transparent,
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

  // Widget _buildTotalSection(TextEditingController totalAmount) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "Enter Amount",
  //           style: GoogleFonts.redHatDisplay(
  //             textStyle:  TextStyle(
  //               color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         TextField(
  //           controller: totalAmount,
  //           keyboardType: TextInputType.number,
  //           decoration: InputDecoration(
  //             hintText: "amount",
  //             hintStyle:  TextStyle(
  //               color: uiMode.value == AppUiModes.dark ? Colors.black : Colors.grey,
  //               fontSize: 14,
  //             ),
  //             filled: true,
  //             fillColor: uiMode.value == AppUiModes.dark ? Colors.grey[500] : Colors.grey[200],
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10.0),
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                "💸Request Queued!",
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
                "Your withdrawal request has been successfully submitted and is now in the queue for processing. 😉",
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
