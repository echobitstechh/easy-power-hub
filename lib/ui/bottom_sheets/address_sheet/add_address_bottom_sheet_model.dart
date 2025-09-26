
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';

class AddAddressBottomSheetModel extends BaseViewModel {

  void loadAddressForEdit(Address address) {
    houseAddressController.text = address.address ?? '';
    cityController.text = address.city ?? '';
    stateController.text = address.state ?? '';
    phoneNumberController.text = address.phoneNumber ?? '';
    _selectedDeliveryZone = address.deliveryZone;
    notifyListeners();
  }

  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();

  final houseAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final phoneNumberController = TextEditingController();

  DeliveryZone? _selectedDeliveryZone;
  DeliveryZone? get selectedDeliveryZone => _selectedDeliveryZone;

  void setSelectedDeliveryZone(DeliveryZone? zone) {
    _selectedDeliveryZone = zone;
    notifyListeners();
  }

  Future<bool> createNewShipping() async {
    setBusy(true);
    try {
      final response = await _repo.saveShipping({
        "address": houseAddressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "phoneNumber": phoneNumberController.text,
        "type": "Shipping",
        "zoneId": _selectedDeliveryZone?.id ?? '',
      });

      if (response.statusCode == 201) {
        _snackBar.showSnackbar(message: "Created address successfully");
        return true;
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
        return false;
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to create address: $e");
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> editShippingAddress(String addressId) async {
    setBusy(true);
    try {
      final response = await _repo.editShipping(addressId, {
        "address": houseAddressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "phoneNumber": phoneNumberController.text,
        "zoneId": _selectedDeliveryZone?.id ?? '',
      });
      if (response.statusCode == 200) {
        _snackBar.showSnackbar(message: "Address updated successfully", duration: Duration(seconds: 2));
        return true;
      } else {
        _snackBar.showSnackbar(message: response.data["message"], duration: Duration(seconds: 2));
        return false;
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to update address: $e", duration: Duration(seconds: 2));
      return false;
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    houseAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}