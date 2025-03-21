import 'package:easyph/state.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'change_password_viewmodel.dart';

class ChangePasswordView extends StackedView<ChangePasswordViewModel> {
  final bool isResetPassword;

  const ChangePasswordView({
    this.isResetPassword = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChangePasswordViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title:  Text('Change password',
                style: TextStyle(color: uiMode.value == AppUiModes.dark ? kcWhiteColor : Colors.black)),
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: kcBlackColor,
              ),
            ),
            // expandedHeight: 200,
            // flexibleSpace: Background(
            //   children: [
            //     Positioned(
            //       top: 30,
            //       left: 0,
            //       right: 0,
            //       bottom: 0,
            //       child: Padding(
            //         padding: const EdgeInsets.all(80.0),
            //         child: Image.asset("assets/images/easyph_light.png"),
            //       ),
            //     )
            //   ],
            // ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        verticalSpaceMedium,
                        TextFieldWidget(
                          obscureText: viewModel.obscure,
                          hint: " current Password",
                          controller: viewModel.oldPassword,
                          suffix: InkWell(
                            onTap: () {
                              viewModel.toggleObscure();
                            },
                            child: Icon(viewModel.obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    TextFieldWidget(
                      obscureText: viewModel.obscure,
                      hint: " New Password",
                      controller: viewModel.newPassword,
                      suffix: InkWell(
                        onTap: () {
                          viewModel.toggleObscure();
                        },
                        child: Icon(viewModel.obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                    verticalSpaceMedium,
                    TextFieldWidget(
                      obscureText: viewModel.obscure,
                      hint: " Confirm Password",
                      controller: viewModel.confirmPassword,
                      suffix: InkWell(
                        onTap: () {
                          viewModel.toggleObscure();
                        },
                        child: Icon(viewModel.obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                    verticalSpaceMedium,
                    SubmitButton(
                      isLoading: viewModel.isBusy,
                      label: "Update Password",
                      submit: () {
                        viewModel.changePassword(context, isResetPassword); 
                      },
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
  ChangePasswordViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChangePasswordViewModel();
}
