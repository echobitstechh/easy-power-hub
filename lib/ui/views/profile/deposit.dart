import 'package:easyph/app/app.router.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/views/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import '../../../utils/money_util.dart';
import '../../components/payment_success_page.dart';

class Deposit extends StatefulWidget {
  const Deposit({Key? key}) : super(key: key);

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  final amount = TextEditingController();
  bool isLoading = false;
  // final plugin = PaystackPlugin();

  @override
  void initState() {
    // plugin.initialize(publicKey: MoneyUtils().payStackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deposit"),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the amount you wish to deposit",
              style: TextStyle(),
            ),
            verticalSpaceLarge,
            // TextFieldWidget(hint: "Amount", controller: amount),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MoneyUtils(),
            ],
            decoration: const InputDecoration(
              hintText: "Amount",
            ),
          ),
            verticalSpaceMedium,
            SubmitButton(
              isLoading: isLoading,
              label: "Continue",
              submit: () async {
                setState(() {
                  isLoading = true;
                });
                // chargeCard();
              },
              color: kcPrimaryColor,
            )
          ],
        ),
      ),
    );
  }





  // chargeCard() async {
  //   var charge = Charge()
  //     ..amount = MoneyUtils().getAmountAsInt(amount) *
  //         100 //the money should be in kobo hence the need to multiply the value by 100
  //     ..reference = MoneyUtils().getReference()
  //     ..email = profile.value.email;
  //   CheckoutResponse response = await plugin.checkout(
  //     context,
  //     method: CheckoutMethod.card,
  //     charge: charge,
  //   );
  //   if (response.status == true) {
  //   ApiResponse res = await locator<Repository>().initTransaction(
  //   {
  //   "amount": MoneyUtils().getAmountAsInt(amount),
  //   "reference": charge.reference
  //   });
  //
  //     if (res.statusCode == 200) {
  //
  //        showSuccess();
  //     } else {
  //       locator<SnackbarService>()
  //           .showSnackbar(message: res.data["message"]);
  //     }
  //   }
  // }

  showSuccess(){

    Navigator.pop(context);

    //return Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => PaymentSuccessPage(
    //     title: "Wallet Funded Sucessfully!",
    //             animation: 'payment_success.json',
    //             callback: () {
    //               ProfileViewModel().getProfile();
    //               Navigator.popUntil(context, ModalRoute.withName(Routes.wallet));
    //               Navigator.pushReplacementNamed(context, Routes.wallet);
    //
    //               // Navigator.popAndPushNamed(context, Routes.wallet);
    //               // locator<NavigationService>()
    //               //     .clearStackAndShow(Routes.wallet )?.whenComplete(() =>
    //               //     ProfileViewModel().getProfile());
    //               }
    //   ),
    // ),);
    // return showModalBottomSheet(
    //   isScrollControlled: true,
    //   context: context,
    //   builder: (BuildContext context) {
    //     return PaymentSuccessPage(
    //         title: "Wallet Funded Sucessfully!",
    //         animation: 'payment_success.json',
    //         callback: () {
    //           locator<NavigationService>()
    //               .navigateToWallet(
    //               wallet: profile.value.wallet ?? Wallet());
    //         });
    //     // ReceiptWidget(info: info,);
    //   },
    // );
  }

  // void showReceipt() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ReceiptWidget(
  //
  //       );
  //     },
  //   );
  // }
}
