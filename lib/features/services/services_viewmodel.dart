
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/models/service.dart';
import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../core/data/repositories/repository.dart';
import '../../core/network/api_response.dart';

class ServicesviewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("ServicesviewModel");
  final _snackBar = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String searchQuery = '';
  List<Service> services = [];
  List<Service> filteredServices = [];

  Future<void> init() async {
    await runBusyFuture(getServices());
  }

  Future<void> getServices() async {
    setBusy(true);
    try {
      ApiResponse res = await _repo.getServices();
      if (res.statusCode == 200 && res.data != null) {
        services = (res.data['services'] as List)
            .map((data) => Service.fromJson(data))
            .toList();
        filteredServices = services;
        notifyListeners();
      } else {
        _log.e('Unexpected API response: ${res.data}');
        _snackBar.showSnackbar(message: 'Failed to fetch services.');
      }
    } catch (e) {
      _log.e('Error fetching services: $e');
      _snackBar.showSnackbar(message: 'An error occurred while fetching services.');
    } finally {
      setBusy(false);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      filteredServices = services;
    } else {
      filteredServices = services.where((service) {
        final name = service.name.toLowerCase();
        final description = service.description?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> callNumber(String phoneNumber) async {
    final res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res != true) {
      _snackBar.showSnackbar(message: 'Could not launch dialer.');
    }
  }

  Future<void> openWhatsAppChat(String serviceName, String phoneNumber) async {
    String cleanedPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : '+234$phoneNumber';
    String message = Uri.encodeFull("Hello, I want more info on the service *$serviceName*");
    String whatsappUrl = "https://wa.me/$cleanedPhoneNumber?text=$message";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      _snackBar.showSnackbar(message: 'Could not launch WhatsApp chat.');
    }
  }

  void showServiceAddressSheet(BuildContext context) {
    // We would use a Stacked dialog or bottom sheet here.
    _dialogService.showCustomDialog(
      // Example of a dialog call
      title: 'Service Address',
      mainButtonTitle: 'Place Order',
      description: 'Enter your details to place a service order.',
      customData: {
        'dateController': dateController,
        'timeController': timeController,
      },
    );
  }
}