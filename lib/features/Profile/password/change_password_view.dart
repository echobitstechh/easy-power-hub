
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/submit_button.dart';
import '../../../ui/components/text_field_widget.dart';
import 'change_password_viewmodel.dart';

class ChangePasswordView extends StatelessWidget {
  final bool isResetPassword;

  const ChangePasswordView({
    this.isResetPassword = false,
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final formKey = GlobalKey<FormState>();

    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Change password',
              style: TextStyle(
                color: uiMode.value == AppUiModes.dark ? kcWhiteColor : Colors.black,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: "Current Password",
                    controller: viewModel.oldPassword,
                    suffix: IconButton(
                      onPressed: viewModel.toggleObscure,
                      icon: Icon(
                        viewModel.obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    validator: (value) => viewModel.validateOldPassword(value),
                  ),
                  verticalSpaceMedium,
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: "New Password",
                    controller: viewModel.newPassword,
                    suffix: IconButton(
                      onPressed: viewModel.toggleObscure,
                      icon: Icon(
                        viewModel.obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    validator: (value) => viewModel.validateNewPassword(value),
                  ),
                  verticalSpaceMedium,
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: "Confirm New Password",
                    controller: viewModel.confirmPassword,
                    suffix: IconButton(
                      onPressed: viewModel.toggleObscure,
                      icon: Icon(
                        viewModel.obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    validator: (value) => viewModel.validateConfirmPassword(value),
                  ),
                  verticalSpaceMedium,
                  SubmitButton(
                    isLoading: viewModel.isBusy,
                    label: "Update Password",
                    submit: () {
                      if (formKey.currentState!.validate()) {
                        viewModel.changePassword(isResetPassword: isResetPassword);
                      }
                    },
                    boldText: true,
                    color: kcPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  ChangePasswordViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      ChangePasswordViewModel();
}