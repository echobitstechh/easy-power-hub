import 'package:easy_power/ui/common/app_colors.dart';
import 'package:easy_power/ui/common/ui_helpers.dart';
import 'package:easy_power/ui/components/submit_button.dart';
import 'package:easy_power/ui/components/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
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
            expandedHeight: 200,
            flexibleSpace:  Positioned(
              top: 30,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset("assets/images/logo.png"),
            )
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpaceLarge,
                    const Text(
                      "OTP Verification",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Panchang"
                      ),
                    ),
                    const Text(
                      "We have sent a code to your Email Address",
                      style: TextStyle(fontSize: 14),
                    ),
                    verticalSpaceMedium,
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
