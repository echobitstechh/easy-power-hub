import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/background.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'delete_account_viewmodel.dart';

class DeleteAccountView extends StackedView<DeleteAccountViewModel> {
  const DeleteAccountView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeleteAccountViewModel viewModel,
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
            flexibleSpace: const Background(
              children: [
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(80.0),
                    // child: Image.asset(""),
                  ),
                )
              ],
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpaceMassive,
                    const Text(
                      "Delete Account",
                      style: TextStyle(fontSize: 18),
                    ),
                    verticalSpaceMedium,
                    TextFieldWidget(
                        hint: "Enter Email", controller: viewModel.email),
                    verticalSpaceMedium,
                    viewModel.emailVerified
                        ? Column(
                            children: [
                              TextFieldWidget(
                                hint: "Enter Code",
                                controller: viewModel.code,
                              ),
                              verticalSpaceMedium,
                            ],
                          )
                        : const SizedBox(),
                    SubmitButton(
                      isLoading: viewModel.isBusy,
                      label: viewModel.emailVerified ? "Submit" : "Continue",
                      submit: () {
                        if (!viewModel.emailVerified) {
                          viewModel.sendCode();
                        } else {
                          viewModel.delete();
                        }
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
  DeleteAccountViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeleteAccountViewModel();
}
