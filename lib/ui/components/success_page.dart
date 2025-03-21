import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SuccessPage extends StatefulWidget {
  final String title;
  final String description;
  final Function callback;

  const SuccessPage({
    required this.title,
    required this.description,
    required this.callback,
    Key? key,
  }) : super(key: key);

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPrimaryColor,
      body: Column(
        children: [
          // Image at the top center
          Padding(
            padding: const EdgeInsets.only(top: 100.0), // Adjust padding as needed
            child: Center(
              child: SvgPicture.asset(
                'assets/images/success_logo.svg', // Replace with your image path
                width: 70,
                height: 70,
              ),
            ),
          ),
          Spacer(), // Pushes the text and button to the bottom
          // Text and button at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kcSecondaryColor,
                  ),
                ),
                verticalSpaceSmall,
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kcWhiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpaceMedium,
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kcWhiteColor),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
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
                  ),
                ),
                verticalSpaceMedium, // Add some space at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}
