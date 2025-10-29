import 'package:easy_ph/core/data/models/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
// import 'package:intl/intl.dart';

import '../../../ui/common/ui_helpers.dart';
import '../../../core/data/models/address.dart';
import './service_request_viewmodel.dart';
import '../../../../ui/components/text_field_widget.dart';
class RequestServiceView extends StackedView<ServiceRequestViewModel> {
  final Service? preselectedService;

  const RequestServiceView({Key? key, this.preselectedService})
      : super(key: key);

  @override
  Widget builder(
      BuildContext context, ServiceRequestViewModel viewModel, Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: viewModel.navigateBack,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 16),
                        horizontalSpaceTiny,
                        Text(
                          'BACK',
                          style: GoogleFonts.redHatDisplay(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Service',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      Text(
                        'Book a service appointment',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      verticalSpaceMedium,

                      Text(
                        'Service Type',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      TextFieldWidget(
                        hint: 'Enter service name',
                        controller: viewModel.serviceNameController,
                        readOnly: viewModel.isPreselectedService,
                        filled: viewModel.isPreselectedService,
                        fillColor: viewModel.isPreselectedService
                            ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
                            : null,
                        borderColor: Colors.grey[300],
                        focusedBorderColor: Colors.orange,
                      ),
                      verticalSpaceSmall,

                      Text(
                        'Address',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      viewModel.isLoadingAddresses
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  horizontalSpaceSmall,
                                  Text(
                                    'Loading addresses...',
                                    style: GoogleFonts.redHatDisplay(
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : viewModel.addresses.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No addresses found',
                                        style: GoogleFonts.redHatDisplay(
                                          textStyle: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          viewModel.navigateToShippingAddresses();
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Add Address',
                                          style: GoogleFonts.redHatDisplay(
                                            textStyle: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<Address>(
                                value: viewModel.selectedAddress,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: 'Select Address',
                                  hintStyle: GoogleFonts.redHatDisplay(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  suffixIcon: const Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.orange),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                items: viewModel.addresses.map((address) {
                                  return DropdownMenuItem<Address>(
                                    value: address,
                                    child: Text(
                                      address.displayAddress,
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  );
                                }).toList(),
                                onChanged: viewModel.setSelectedAddress,
                                selectedItemBuilder: (BuildContext context) {
                                  return viewModel.addresses.map((address) {
                                    return Text(
                                      address.displayAddress,
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    );
                                  }).toList();
                                },
                              ),

                      verticalSpaceSmall,

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preferred Date',
                                  style: GoogleFonts.redHatDisplay(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                verticalSpaceTiny,
                                TextFieldWidget(
                                  hint: 'dd/mm/yyyy',
                                  controller: viewModel.dateController,
                                  readOnly: true,
                                  suffix: const Icon(Icons.calendar_today, size: 20),
                                  onTap: () => viewModel.selectDate(context),
                                  borderColor: Colors.grey[300],
                                  focusedBorderColor: Colors.orange,
                                ),
                              ],
                            ),
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preferred Time',
                                  style: GoogleFonts.redHatDisplay(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                verticalSpaceTiny,
                                TextFieldWidget(
                                  hint: 'Select time',
                                  controller: viewModel.timeController,
                                  readOnly: true,
                                  suffix: const Icon(Icons.access_time, size: 20),
                                  onTap: () => viewModel.selectTime(context),
                                  borderColor: Colors.grey[300],
                                  focusedBorderColor: Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceSmall,

                      // Description and Attachment (Only show for custom service)
                      // if (!viewModel.isPreselectedService) ...[
                      Text(
                        'Description (Optional)',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      TextFieldWidget(
                        hint: 'Describe the issue or service needed...',
                        controller: viewModel.descriptionController,
                        maxLines: 4,
                        borderColor: Colors.grey[300],
                        focusedBorderColor: Colors.orange,
                      ),
                      verticalSpaceSmall,

                      Text(
                        'Attachment (Optional)',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      GestureDetector(
                        onTap: viewModel.pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  viewModel.selectedImageName ??
                                      'Add picture of item',
                                  style: GoogleFonts.redHatDisplay(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      color: viewModel.selectedImageName != null
                                          ? (isDarkMode
                                              ? Colors.white
                                              : Colors.black87)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.attach_file,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      // ],

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: viewModel.navigateBack,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                foregroundColor:
                                    isDarkMode ? Colors.white : Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: ElevatedButton(
                              onPressed: viewModel.isBusy
                                  ? null
                                  : () => viewModel.submitRequest(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 0,
                              ),
                              child: viewModel.isBusy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Schedule',
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  @override
  ServiceRequestViewModel viewModelBuilder(BuildContext context) {
    return ServiceRequestViewModel();
  }

  @override
  void onViewModelReady(ServiceRequestViewModel viewModel) {
    viewModel.initialize(service: preselectedService);
    super.onViewModelReady(viewModel);
  }
}
