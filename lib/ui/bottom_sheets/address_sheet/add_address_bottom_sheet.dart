
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../features/Profile/shipping/shipping_address_viewmodel.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'add_address_bottom_sheet_model.dart';


class AddAddressBottomSheet extends StackedView<AddAddressBottomSheetModel> {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const AddAddressBottomSheet({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
      BuildContext context,
      AddAddressBottomSheetModel viewModel,
      Widget? child,
      ) {
    final parentViewModel = (request.data as Map)['viewModel'] as ShippingAddressesViewModel;
    final Address? addressToEdit = (request.data as Map)['addressToEdit'] as Address?;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? kcDarkGreyColor
            : kcWhiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            verticalSpaceMedium,
            TextFieldWidget(
              hint: 'House address',
              controller: viewModel.houseAddressController,
            ),
            verticalSpaceSmall,
            TextFieldWidget(
              hint: 'City',
              controller: viewModel.cityController,
            ),
            verticalSpaceSmall,
            TextFieldWidget(
              hint: 'State/Nationality',
              controller: viewModel.stateController,
            ),
            verticalSpaceSmall,
            TextFieldWidget(
              hint: 'Phone Number',
              controller: viewModel.phoneNumberController,
              inputType: TextInputType.phone,
            ),
            verticalSpaceSmall,
            DropdownButtonFormField<DeliveryZone>(
              decoration: const InputDecoration(
                labelText: "Delivery Zone",
                border: OutlineInputBorder(),
              ),
              value: parentViewModel.deliveryZones.contains(viewModel.selectedDeliveryZone)
                  ? viewModel.selectedDeliveryZone
                  : null,
              items: parentViewModel.deliveryZones.map((zone) {
                return DropdownMenuItem<DeliveryZone>(
                  value: zone,
                  child: Text('${zone.name} (${zone.baseFee?.toStringAsFixed(0) ?? ''} NGN)'),
                );
              }).toList(),
              onChanged: (zone) {
                viewModel.setSelectedDeliveryZone(zone);
              },
            ),
            verticalSpaceMedium,
            SubmitButton(
              isLoading: viewModel.isBusy,
              label: addressToEdit != null ? 'Save Changes' : 'Add Address',
              submit: () async {
                if (viewModel.houseAddressController.text.isNotEmpty &&
                    viewModel.cityController.text.isNotEmpty &&
                    viewModel.stateController.text.isNotEmpty &&
                    viewModel.phoneNumberController.text.isNotEmpty &&
                    viewModel.selectedDeliveryZone != null) {

                  bool success;
                  if (addressToEdit != null) {
                    success = await viewModel.editShippingAddress(addressToEdit.id!);
                  } else {
                    success = await viewModel.createNewShipping();
                  }

                  if (success) {
                    await parentViewModel.getShippings();
                    completer(SheetResponse(confirmed: true));
                    Navigator.pop(context);
                  }
                } else {
                  locator<SnackbarService>().showSnackbar(message: "Please fill all fields", duration: const Duration(seconds: 3));
                }
              },
              color: kcPrimaryColor,
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  @override
  AddAddressBottomSheetModel viewModelBuilder(BuildContext context) => AddAddressBottomSheetModel();

  @override
  void onViewModelReady(AddAddressBottomSheetModel viewModel) {
    // Check for the address to edit and load it only once
    final Address? addressToEdit = (request.data as Map)['addressToEdit'] as Address?;
    if (addressToEdit != null) {
      viewModel.loadAddressForEdit(addressToEdit);
    }
    super.onViewModelReady(viewModel);
  }
}

