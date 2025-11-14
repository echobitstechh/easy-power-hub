import 'package:easy_ph/features/services/services_viewmodel.dart';
import 'package:easy_ph/features/services/widgets/service_item.dart';
import 'package:easy_ph/features/services/widgets/service_status_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../state.dart';
import '../../ui/common/app_colors.dart';
import '../../ui/common/ui_helpers.dart';
import '../../ui/components/empty_state.dart';
import '../../ui/components/shimmers/shimmer.dart';

class ServicesView extends StackedView<ServicesviewModel> {
  const ServicesView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, ServicesviewModel viewModel, Widget? child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                        hintText: 'Search on EasyPower Hub',
                        hintStyle: GoogleFonts.redHatDisplay(),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
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

              Expanded(
                child: viewModel.isBusy
                    ? Shimmer.fromColors(
                        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return buildShimmerServiceItem(context);
                          },
                        ),
                      )
                    : ListView(
                        children: [
                          // Grid view for status cards
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                            children: [
                              ServiceStatusCard(
                                title: 'Pending Services',
                                count: viewModel.pendingServicesCount,
                                icon: Icons.pending_outlined,
                                iconBackgroundColor: Colors.orange.withOpacity(0.2),
                                iconColor: Colors.orange,
                              ),
                              ServiceStatusCard(
                                title: 'Accepted Services',
                                count: viewModel.acceptedServicesCount,
                                icon: Icons.build_outlined,
                                iconBackgroundColor: Colors.grey.withOpacity(0.2),
                                iconColor: Colors.grey[700]!,
                              ),
                              ServiceStatusCard(
                                title: 'Completed Services',
                                count: viewModel.completedServicesCount,
                                icon: Icons.check_circle_outline,
                                iconBackgroundColor: Colors.green.withOpacity(0.2),
                                iconColor: Colors.green,
                              ),
                            ],
                          ),
                          verticalSpaceSmall,

                          Row(
                            children: [
                              // Expanded(
                              //   child: ElevatedButton(
                              //     onPressed: viewModel.requestService,
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.orange,
                              //       foregroundColor: Colors.white,
                              //       padding: const EdgeInsets.symmetric(
                              //           vertical: 8.0),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(8.0),
                              //       ),
                              //     ),
                              //     child: Text(
                              //       'Custom Service',
                              //       style: GoogleFonts.redHatDisplay(
                              //         textStyle: const TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: viewModel.viewExistingServices,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'View Existing Services',
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
                          verticalSpaceSmall,

                          // Service Items List
                          if (viewModel.filteredServices.isEmpty)
                            const SizedBox(
                              height: 300,
                              child: EmptyState(
                                animation:
                                    "assets/animations/empty_notifications.json",
                                label: "No Services yet",
                              ),
                            )
                          else
                            ...viewModel.filteredServices.map((service) {
                              return ServiceItem(
                                service: service,
                                viewModel: viewModel,
                              );
                            }).toList(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  ServicesviewModel viewModelBuilder(BuildContext context) {
    return ServicesviewModel();
  }

  @override
  void onViewModelReady(ServicesviewModel viewModel) {
    viewModel.getServices();
    super.onViewModelReady(viewModel);
  }
}