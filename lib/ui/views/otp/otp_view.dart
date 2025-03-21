import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';

import '../../components/background.dart';
import 'otp_viewmodel.dart';

class OtpView extends StackedView<OtpViewModel> {
  final String email;

  const OtpView({
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    OtpViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: kcWhiteColor,
              ),
            ),
            expandedHeight: 100,
            // flexibleSpace:
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/otp_lock.svg',
                        height: 94,
                      ),
                    ),
                    verticalSpaceLarge,
                    const Text(
                      "OTP Verification",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Panchang"
                      ),
                    ),
                    const Text(
                      "We have sent a code to your Email Address",
                      style: TextStyle(fontSize: 14),
                    ),
                    verticalSpaceLarge,
                    TextFieldWidget(
                        hint: "Enter Code", controller: viewModel.otp),
                    Row(
                        children:  [
                          const Text(
                            "Didnt get the OTP? ",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              viewModel.resendOtp(email, context);
                            },
                            child: const Text(
                              "Click here to resend",
                              style: TextStyle(
                                fontSize: 14,
                                color: kcSecondaryColor,
                              ),
                            ),
                          )

                        ]
                    ),
                    verticalSpaceMedium,
                    SubmitButton(
                      isLoading: viewModel.isBusy,
                      label: "Verify account",
                      submit: () => viewModel.verify(email, context),
                      boldText: true,
                      color: kcPrimaryColor,
                    ),
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  @override
  OtpViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      OtpViewModel();
}
