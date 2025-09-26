
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';

class ShippingAddressesViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();

  final houseAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final phoneNumberController = TextEditingController();

  List<Address> _shippingAddresses = [];
  List<DeliveryZone> _deliveryZones = [];
  DeliveryZone? _selectedDeliveryZone;

  List<Address> get shippingAddresses => _shippingAddresses;
  List<DeliveryZone> get deliveryZones => _deliveryZones;
  DeliveryZone? get selectedDeliveryZone => _selectedDeliveryZone;


  Future<void> init() async {
    setBusy(true);
    await Future.wait([
      getShippings(),
      getDeliveryZones(),
    ]);
    setBusy(false);
  }

  void setSelectedDeliveryZone(DeliveryZone? zone) {
    _selectedDeliveryZone = zone;
    notifyListeners();
  }

  Future<void> deleteAddress(int index) async {
    setBusy(true);
    try {
      final addressId = _shippingAddresses[index].id;
      if (addressId == null) {
        _snackBar.showSnackbar(message: "Address ID is missing.", duration: const Duration(seconds: 2));
        return;
      }

      final response = await _repo.deleteShipping(addressId);

      if (response.statusCode == 200) {
        // If the API call is successful, remove the address from the local list
        _shippingAddresses.removeAt(index);
        _snackBar.showSnackbar(message: "Address deleted successfully.", duration: const Duration(seconds: 2));
      } else {
        _snackBar.showSnackbar(message: response.data["message"] ?? "Failed to delete address.", duration: const Duration(seconds: 2));
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to delete address: $e", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }


  Future<void> getShippings() async {
    try {
      final response = await _repo.getAddresses();
      if (response.statusCode == 200) {
        final List<dynamic> addressList = response.data['data'] ?? [];
        _shippingAddresses = addressList
            .map((item) => Address.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to fetch addresses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> getDeliveryZones() async {
    try {
      final response = await _repo.getDeliveryZones();
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['zones'] ?? [];
        _deliveryZones = list.map((item) => DeliveryZone.fromJson(item)).toList();
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to fetch delivery zones: $e");
    }
  }

  // Method to show the add address dialog
  void showAddAddressBottomSheet() {
    _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.addAddressBottom,
        isScrollControlled: true,
        title: 'Add Address',
        data: {
          'viewModel': this,
        }
    );
  }

  void showEditAddressBottomSheet(Address address) {
    _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.addAddressBottom,
        isScrollControlled: true,
        title: 'Edit Address',
        data: {
          'viewModel': this,
          'addressToEdit': address,
        });
  }
}