import 'package:easyph/state.dart';
import 'package:easyph/ui/common/ui_helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app.locator.dart';
import '../../common/app_colors.dart';
import '../../components/empty_state.dart';
import '../../components/shimmer.dart';
import '../../components/submit_button.dart';
import 'service_viewmodel.dart';

class ServicesView extends StackedView<ServicesviewModel> {
  const ServicesView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, ServicesviewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services',
          style: GoogleFonts.redHatDisplay(
            textStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.getServices,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              verticalSpaceSmall,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: viewModel.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search on Easy Power',
                        hintStyle: GoogleFonts.redHatDisplay(),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: uiMode.value == AppUiModes.dark
                            ? kcMediumGrey
                            : kcWhiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpaceSmall,
              viewModel.isBusy
                  ? Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return buildShimmerServiceItem(context);
                    },
                  ),
                ),
              )
                  : viewModel.filteredServices.isEmpty
                  ? const Expanded(
                child: EmptyState(
                  animation: "empty_notifications.json",
                  label: "No Services yet",
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: viewModel.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = viewModel.filteredServices[index];
                    return _buildServiceItem(
                      context,
                      service.image ?? 'assets/images/default.png',
                      service.name,
                      service.description,
                      service.phoneNumber ?? 'N/A',
                      '\$${service.price.toStringAsFixed(2)}',
                      viewModel,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String imagePath, String title,
      String description,String phoneNumber, String price,ServicesviewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                height: 90,
                width: 86,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/default.png',
                      height: 90, width: 86);
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: GoogleFonts.redHatDisplay(
                      textStyle:
                      TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: () => _openWhatsAppChat(title, "Service Image URL", phoneNumber),
                ),
                const SizedBox(height: 0.0),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed:()=> _callNumber(phoneNumber),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  void showServiceAddressSheet(BuildContext context,ServicesviewModel viewModel, Function onPlaceOrder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
      true, // Allows the bottom sheet to adjust for the keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Column(
              mainAxisSize:
              MainAxisSize.min, // Minimize the size of the bottom sheet
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Service Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "House Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "State / Nationality",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: viewModel.dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Date of Service",
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              // Format the date as needed (e.g., MM/dd/yyyy)
                              final formattedDate =
                                  "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}";

                              // Update the text field
                              viewModel.dateController.text = formattedDate;
                              // Handle selected date
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: viewModel.timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Time of Service",
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((selectedTime) {
                            if (selectedTime != null) {
                              // Handle selected time
                              // Format the time as needed (e.g., HH:mm AM/PM)
                              final formattedTime = selectedTime.format(
                                  context);

                              // Update the text field
                              viewModel.timeController.text = formattedTime;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixText: "+234 ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Row(
                //   children: [
                //     Checkbox(
                //       value: true, // Set this dynamically based on the state
                //       onChanged: (value) {
                //         // Handle checkbox toggle
                //       },
                //     ),
                //     Text("Set as default payment method"),
                //   ],
                // ),
                const SizedBox(height: 16),
                SubmitButton(
                  isLoading: false,
                  label: "place Order",
                  submit: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Checkout(
                    //       infoList: [],
                    //     ),
                    //   ),
                    // );
                  },
                  color: kcSecondaryColor,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  ServicesviewModel viewModelBuilder(BuildContext context) {
    return ServicesviewModel();
  }

  @override
  void onViewModelReady(ServicesviewModel viewModel) {
    viewModel.getServices(); // Fetch services when the view model is ready
    super.onViewModelReady(viewModel);
  }
}

final SnackbarService _snackBar = locator<SnackbarService>();

void _callNumber(String phoneNumber) async {
  bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  if (res != true) {
    _snackBar.showSnackbar(message: "Could not launch dialer.");
  }
}

void _openWhatsAppChat(String serviceName, String serviceImage, String phoneNumber) async {
  String cleanedPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber :'+234$phoneNumber';

  String message = Uri.encodeFull(
      "Hello, I want more info on the service *$serviceName*");

  String whatsappUrl = "https://wa.me/$cleanedPhoneNumber?text=$message";

  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
    await launchUrl(Uri.parse(whatsappUrl));
  } else {
    throw 'Could not launch WhatsApp chat';
  }
}