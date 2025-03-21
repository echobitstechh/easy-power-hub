
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/background.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


class PaymentSuccessPage extends StatefulWidget {
  final String title;
  final String animation;
  final Function callback;

  const PaymentSuccessPage({
    required this.title,
    required this.animation,
    required this.callback,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset("assets/animations/${widget.animation}"),
                          verticalSpaceMedium,
                          Text(
                            widget.title,
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                              verticalSpaceMedium,
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kcWhiteColor)),
                        onPressed: () {
                          widget.callback();
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kcPrimaryColor,
                          ),
                        ),
                      )
                ],
              ))
        ],
      ),
    );
  }
}
