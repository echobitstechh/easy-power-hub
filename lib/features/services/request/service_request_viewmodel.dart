import 'dart:io';
import 'dart:convert';
import 'package:easy_ph/features/services/widgets/ServiceSuccessView.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_ph/core/utils/date_time_util.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.logger.dart';
import '../../../core/network/api_response.dart';
import '../../../core/data/models/service.dart';
import '../../../core/data/models/address.dart';
import '../../../core/data/repositories/repository.dart';

class ServiceRequestViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackBar = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _repo = locator<Repository>();
  final _log = getLogger("RequestServiceViewModel");
  final _imagePicker = ImagePicker();

  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedImagePath;
  String? _selectedImageName;
  Service? _preselectedService;
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoadingAddresses = false;

  bool get isPreselectedService => _preselectedService != null;
  String? get selectedImageName => _selectedImageName;
  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoadingAddresses => _isLoadingAddresses;

  void initialize({Service? service}) async {
    if (service != null) {
      _preselectedService = service;
      serviceNameController.text = service.name;
    }
    await fetchAddresses();
    notifyListeners();
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void navigateBack() {
    _navigationService.back();
  }

  Future<void> fetchAddresses() async {
    _isLoadingAddresses = true;
    notifyListeners();

    try {
      ApiResponse res = await _repo.getAddresses();
      
      if (res.statusCode == 200 && res.data != null) {
        _addresses = (res.data['data'] as List)
            .map((data) => Address.fromJson(data))
            .toList();
        _log.i('Fetched ${_addresses.length} addresses');
      } else {
        _log.e('Failed to fetch addresses');
        _snackBar.showSnackbar(
          message: 'Could not load addresses',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('Error fetching addresses: $e');
      _snackBar.showSnackbar(
        message: 'Error loading addresses',
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void setSelectedAddress(Address? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final selectedDate = await DateTimeUtil.selectDate(context);
    if (selectedDate != null) {
      dateController.text = selectedDate;
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final selectedTime = await DateTimeUtil.selectTime(context);
    if (selectedTime != null) {
      timeController.text = selectedTime;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    try {
      final result = await _dialogService.showDialog(
        title: 'Select Image Source',
        description: 'Choose where to get the image from',
        buttonTitle: 'Gallery',
        cancelTitle: 'Camera',
      );

      ImageSource source;
      if (result?.confirmed == true) {
        source = ImageSource.gallery;
      } else if (result?.confirmed == false) {
        source = ImageSource.camera;
      } else {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImagePath = image.path;
        _selectedImageName = image.name;
        notifyListeners();

        _snackBar.showSnackbar(
          message: 'Image selected successfully',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('Error picking image: $e');
      _snackBar.showSnackbar(
        message: 'Failed to pick image. Please try again.',
      );
    }
  }

  bool _validateForm() {
    if (_preselectedService == null) {
      _snackBar.showSnackbar(message: 'Service ID is missing');
      return false;
    }

    if (_selectedAddress == null) {
      _snackBar.showSnackbar(message: 'Please select an address');
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      _snackBar.showSnackbar(message: 'Please select a preferred date');
      return false;
    }

    if (timeController.text.trim().isEmpty) {
      _snackBar.showSnackbar(message: 'Please select a preferred time');
      return false;
    }

    return true;
  }

  Future<String?> _imageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg'; // default
      if (imagePath.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (imagePath.toLowerCase().endsWith('.jpg') || 
                 imagePath.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      _log.e('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> submitRequest(BuildContext context) async {
    if (!_validateForm()) return;

    setBusy(true);
    try {
      List<String> attachments = [];
      if (_selectedImagePath != null) {
        final base64Image = await _imageToBase64(_selectedImagePath!);
        if (base64Image != null) {
          attachments.add(base64Image);
        }
      }

      final formattedDate = DateTimeUtil.convertDateFormat(dateController.text.trim());

      final requestBody = {
        'serviceId': _preselectedService!.id,
        'addressId': _selectedAddress!.id,
        'date': formattedDate,
        'time': timeController.text.trim(),
        'description': descriptionController.text.trim(),
        'attachments': attachments,
      };

      _log.i('Submitting service request: $requestBody');

      ApiResponse res = await _repo.requestService(requestBody);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _log.i('Service request successful: ${res.data}');
        _navigateToSuccess(context);
      } else {
        _log.e('Service request failed: ${res.statusCode}');
        _snackBar.showSnackbar(
          message: 'Failed to submit request. Please try again.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _log.e('Error submitting service request: $e');
      _snackBar.showSnackbar(
        message: 'An error occurred. Please try again.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

void _navigateToSuccess(BuildContext context) {  // ← Add context parameter
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SuccessView.serviceScheduled(
        onButtonPressed: () {
          Navigator.of(context).pop(); // Pop success view
          Navigator.of(context).pop(); // Pop request view
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

  void navigateToShippingAddresses() => _navigationService.navigateTo(Routes.shippingAddressesPage);
}