import 'package:flutter/material.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'phone_input_dialog_model.dart';

class PhoneInputDialog extends StackedView<PhoneInputDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const PhoneInputDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      PhoneInputDialogModel viewModel,
      Widget? child,
      ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.title!,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900),
            ),
            verticalSpaceTiny,
            Text(
              request.description!,
              style: const TextStyle(fontSize: 14, color: kcMediumGrey),
              maxLines: 2,
              softWrap: true,
            ),
            verticalSpaceMedium,
            TextField(
              controller: viewModel.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => completer(DialogResponse(confirmed: false)),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Return the entered text on confirmation
                    completer(DialogResponse(
                      confirmed: true,
                      data: viewModel.phoneController.text,
                    ));
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  PhoneInputDialogModel viewModelBuilder(BuildContext context) =>
      PhoneInputDialogModel();
}