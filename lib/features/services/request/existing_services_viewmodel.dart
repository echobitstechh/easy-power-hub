import 'package:easy_ph/app/app.dialogs.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/service_request.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import './request_details_view.dart';

class ExistingServicesViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackBar = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _repo = locator<Repository>();
  final _log = getLogger("ExistingServicesViewModel");

  List<ServiceRequest> _serviceRequests = [];
  List<ServiceRequest> get serviceRequests => _serviceRequests;

  int _pendingServicesCount = 0;
  int _acceptedServicesCount = 0;
  int _completedServicesCount = 0;

  int get pendingServicesCount => _pendingServicesCount;
  int get acceptedServicesCount => _acceptedServicesCount;
  int get completedServicesCount => _completedServicesCount;

  void navigateBack() {
    _navigationService.back();
  }

  void _calculateServiceCounts() {
    _pendingServicesCount = _serviceRequests
        .where((request) => request.status.toLowerCase() == 'pending')
        .length;
    
    _acceptedServicesCount = _serviceRequests
        .where((request) => request.status.toLowerCase() == 'accepted')
        .length;
    
    _completedServicesCount = _serviceRequests
        .where((request) => request.status.toLowerCase() == 'completed')
        .length;
    
    _log.i('Service counts - Pending: $_pendingServicesCount, Accepted: $_acceptedServicesCount, Completed: $_completedServicesCount');
  }

  Future<void> getServiceRequests({String? status}) async {
    setBusy(true);
    try {
      ApiResponse res = await _repo.getExistingService(
        status: status,
        page: 1,
        limit: 100,
      );
      
      if (res.statusCode == 200 && res.data != null) {
        _log.i('Service requests fetched: ${res.data}');
        
        _serviceRequests = (res.data['data'] as List)
            .map((data) => ServiceRequest.fromJson(data))
            .toList();
        
        _log.i('Parsed ${_serviceRequests.length} service requests');
        
        _calculateServiceCounts();
        
        notifyListeners();
      } else {
        _log.e('Failed to fetch service requests: ${res.statusCode}');
        _snackBar.showSnackbar(
          message: 'Failed to fetch service requests.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('Error fetching service requests: $e');
      _snackBar.showSnackbar(
        message: 'An error occurred while fetching service requests.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }
    
  void viewRequestDetails(BuildContext context, ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => RequestDetailsBottomSheet(
          serviceRequest: request,
          onCancelRequest: () {
            Navigator.pop(context);
            cancelRequest(request.id);
          },
        ),
      ),
    );
  }

  Future<String?> _showReasonDialog() async {
    final result = await _dialogService.showCustomDialog(
      variant: DialogType.serviceRejectReason,
      title: 'Cancellation Reason',
      description: 'Please tell us why you want to cancel this request.',
    );

    if (result?.confirmed == true && result?.data is String) {
      return result!.data;
    }
    return null;
  }

  Future<void> cancelRequest(String requestId) async {
    final result = await _dialogService.showDialog(
      title: 'Cancel Request',
      description: 'Are you sure you want to cancel this service request? Please provide a reason.',
      buttonTitle: 'Cancel',
      cancelTitle: 'Go Back',
    );

    if (result?.confirmed != true) return;

    final reason = await _showReasonDialog();
    if (reason == null || reason.isEmpty) return;

    setBusy(true);
    try {
      ApiResponse res = await _repo.cancelServiceRequest(requestId, reason);
      
      if (res.statusCode == 200) {
        _log.i('Request cancelled successfully');
        _snackBar.showSnackbar(
          message: 'Request cancelled successfully',
          duration: const Duration(seconds: 2),
        );
        
        await getServiceRequests();
      } else {
        _log.e('Failed to cancel request: ${res.statusCode}');
        _snackBar.showSnackbar(
          message: 'Failed to cancel request',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('Error cancelling request: $e');
      _snackBar.showSnackbar(
        message: 'An error occurred. Please try again.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }
}