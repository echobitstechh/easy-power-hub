
import 'package:easy_ph/features/services/services_viewmodel.dart';
import 'package:easy_ph/features/services/widgets/service_item.dart';
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
              viewModel.isBusy
                  ? Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      // This needs to be a reusable shimmer widget
                      return buildShimmerServiceItem(context);
                    },
                  ),
                ),
              )
                  : viewModel.filteredServices.isEmpty
                  ? const Expanded(
                child: EmptyState(
                  animation: "assets/animations/empty_notifications.json",
                  label: "No Services yet",
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: viewModel.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = viewModel.filteredServices[index];
                    return ServiceItem(
                      service: service,
                      viewModel: viewModel,
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