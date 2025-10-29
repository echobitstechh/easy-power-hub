import 'package:easy_ph/features/services/widgets/service_request_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/empty_state.dart';
import '../../../ui/components/shimmers/service_requests_shimmer.dart';
import '../../../../ui/common/app_colors.dart';
import 'existing_services_viewmodel.dart';

class ExistingServicesView extends StackedView<ExistingServicesViewModel> {
  const ExistingServicesView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, ExistingServicesViewModel viewModel, Widget? child) {
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
              child: RefreshIndicator(
                onRefresh: viewModel.getServiceRequests,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Requests',
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: kcSecondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      verticalSpaceTiny,
                      if (!viewModel.isBusy && viewModel.serviceRequests.isNotEmpty)
                        Text(
                          'View all existing services',
                          style: GoogleFonts.redHatDisplay(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      verticalSpaceSmall,
                      
                      Expanded(
                        child: viewModel.isBusy
                            ? const ServiceRequestsShimmer(itemCount: 4)
                            : viewModel.serviceRequests.isEmpty
                                ? const Center(
                                    child: EmptyState(
                                      animation: "assets/animations/empty_notifications.json",
                                      label: "No service requests yet",
                                    ),
                                  )
                                : ListView(
                                    children: [
                                      ...viewModel.serviceRequests.map((request) {
                                        return ServiceRequestItem(
                                          serviceName: request.serviceName,
                                          status: request.status,
                                          date: request.date,
                                          time: request.time,
                                          address: request.address,
                                          description: request.description,
                                          assignedPersonName: request.assignedPersonnel?.name,
                                          assignedPersonPhone: request.assignedPersonnel?.phone,
                                          assignedPersonEmail: request.assignedPersonnel?.email,
                                          onViewDetails: () => viewModel.viewRequestDetails(context, request),
                                          onCancelRequest: (request.status.toLowerCase() == 'pending' ||
                                                  request.status.toLowerCase() == 'accepted')
                                              ? () => viewModel.cancelRequest(request.id)
                                              : null,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ExistingServicesViewModel viewModelBuilder(BuildContext context) {
    return ExistingServicesViewModel();
  }

  @override
  void onViewModelReady(ExistingServicesViewModel viewModel) {
    viewModel.getServiceRequests();
    super.onViewModelReady(viewModel);
  }
}