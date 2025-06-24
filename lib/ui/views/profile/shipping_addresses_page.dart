import 'dart:convert';

import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/network/interceptors.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';

class ShippingAddressesPage extends StatefulWidget {
  const ShippingAddressesPage({Key? key}) : super(key: key);

  @override
  _ShippingAddressesPageState createState() => _ShippingAddressesPageState();
}

class _ShippingAddressesPageState extends State<ShippingAddressesPage> {
  final TextEditingController houseAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  bool loading = false;
  bool isShippingLoading = false;

  List<Address> shippingAddresses = [];
  List<DeliveryZone> deliveryZones = [];
  DeliveryZone? selectedDeliveryZone;

  void deleteAddress(int index) async {
    setState(() {
      shippingAddresses.removeAt(index);
    });

    // Save the updated list to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shippingAddresses', jsonEncode(shippingAddresses));
  }

  void showAddAddressBottomSheet() {
    String name = '';
    String houseAddress = '';
    String city = '';
    String state = '';
    String phoneNumber = '';
    String deliveryZoneId = '';
    bool isDefaultPayment = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add Address',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight
                            .bold),
                      ),
                      const SizedBox(height: 16),

                      TextFieldWidget(
                        hint: 'House address',
                        controller: houseAddressController,
                        onChanged: (value) => houseAddress = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'City',
                        controller: cityController,
                        onChanged: (value) => city = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'State/Nationality',
                        controller: stateController,
                        onChanged: (value) => state = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'Phone Number',
                        controller: phoneNumberController,
                        onChanged: (value) => phoneNumber = value,
                      ),
                      verticalSpaceSmall,

                      DropdownButtonFormField<DeliveryZone>(
                        decoration: const InputDecoration(
                          labelText: "Delivery Zone",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedDeliveryZone,
                        items: deliveryZones.map((zone) {
                          return DropdownMenuItem<DeliveryZone>(
                            value: zone,
                            child: Text('${zone.name} (${zone.baseFee?.toStringAsFixed(0) ?? ''} NGN)'),
                          );
                        }).toList(),
                        onChanged: (zone) {
                          setModalState(() {
                            selectedDeliveryZone = zone;
                          });
                        },
                      ),

                      // const SizedBox(height: 16),
                      // Row(
                      //   children: [
                      //     Checkbox(
                      //       value: isDefaultPayment,
                      //       activeColor: Colors.black,
                      //       checkColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(5)),
                      //       onChanged: (value) {
                      //         setModalState(() {
                      //           isDefaultPayment = value ?? false;
                      //         });
                      //       },
                      //     ),
                      //     const Text("Set as default payment method"),
                      //   ],
                      // ),
                      const SizedBox(height: 16),
                      SubmitButton(
                          isLoading: false,
                          label: 'Add Address',
                          submit: () {
                            if (houseAddressController.text.isNotEmpty &&
                                cityController.text.isNotEmpty &&
                                stateController.text.isNotEmpty &&
                                phoneNumberController.text.isNotEmpty
                                && selectedDeliveryZone != null) {
                              createNewShipping();
                            }
                            houseAddressController.clear();
                            cityController.clear();
                            stateController.clear();
                            phoneNumberController.clear();
                          },
                          color: kcPrimaryColor),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> createNewShipping() async {
    try {
      loading = true;
      final response = await repo.saveShipping({
        "address": houseAddressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "phoneNumber": phoneNumberController.text,
        "type": "Shipping",
        "zoneId": selectedDeliveryZone?.id ?? '',
      });

      if (response.statusCode == 201) {
        locator<SnackbarService>().showSnackbar(message: "Created address successfully", duration: Duration(seconds: 2));
        loading = false;
        getShippings();
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        locator<SnackbarService>().showSnackbar(message: response.data["message"], duration: Duration(seconds: 2));
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to create address: $e", duration: Duration(seconds: 2));
    }finally{
      loading = false;
    }
  }

  Future<void> getShippings() async {
    try {
      isShippingLoading = true;
      final response = await repo.getAddresses();

      if (response.statusCode == 200) {
        // Access the `data` key in the response before mapping
        final List<dynamic> addressList = response.data['data'] ?? [];

        // Parse the address data
        shippingAddresses = addressList
            .map((item) => Address.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        print('Shipping addresses: $shippingAddresses');
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data["message"],
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Failed to fetch addresses: $e",
        duration: Duration(seconds: 2),
      );
    } finally {
      isShippingLoading = false;
      setState(() {}); // Update the UI with the new data
    }
  }

  Future<void> getDeliveryZones() async {
    try {
      final response = await repo.getDeliveryZones();

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['zones'] ?? [];
        deliveryZones = list.map((item) => DeliveryZone.fromJson(item)).toList();
        setState(() {});
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data["message"],
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Failed to fetch delivery zones: $e",
        duration: Duration(seconds: 2),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    getShippings();
    getDeliveryZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
      ),
      body: ListView.builder(
        itemCount: shippingAddresses.length,
        itemBuilder: (context, index) {
          Address address = shippingAddresses[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          address.address ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1, // Ensure it doesn't wrap
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildIconButton(Icons.edit, 'Edit', ),
                      _buildIconButton(Icons.delete, 'Delete'),
                    ],
                  ),
                  Text(address.city ?? '', style: const TextStyle(fontSize: 18),),
                  Text(address.state ?? '',style:  const TextStyle(fontSize: 18),),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: showAddAddressBottomSheet,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, [VoidCallback? onPressed]) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: isDarkMode ? Colors.white : Colors.grey[600],
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}