import 'package:afriprize/state.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';
import 'service_viewmodel.dart';

class ServicesView extends StackedView<ServicesviewModel> {
  const ServicesView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, ServicesviewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services',
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                        fillColor: Colors.grey[100],
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
                  ? const Center(child: CircularProgressIndicator())
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
                      '\$${service.price.toStringAsFixed(2)}',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context, String imagePath, String title, String description, String price) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: (){
          showServiceAddressSheet(context, () {
            // Handle Place Order action
            print("Proceeding to checkout...");
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 100,
                  width: 86,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/default.png', height: 100, width: 86);
                  },
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      description,
                      style: GoogleFonts.redHatDisplay(
                        textStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.more_vert),
                  SizedBox(height: 16.0),
                  Text(
                    price,
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showServiceAddressSheet(BuildContext context, Function onPlaceOrder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to adjust for the keyboard
      shape: RoundedRectangleBorder(
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
          child: SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimize the size of the bottom sheet
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
                SizedBox(height: 16),
                Text(
                  "Service Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "House Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "State / Nationality",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
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
                              // Handle selected date
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
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
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixText: "+234 ",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
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
                SizedBox(height: 16),
                SubmitButton(
                  isLoading: false,
                  label: "place Order",
                  submit: () {

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
