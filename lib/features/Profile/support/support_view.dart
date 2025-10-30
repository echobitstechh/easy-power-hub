
import 'package:easy_ph/features/Profile/support/shipping_viewmodel.dart';
import 'package:easy_ph/features/Profile/support/widget/support_option.dart';
import 'package:easy_ph/features/Profile/widgets/company_address_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SupportView extends StackedView<SupportViewModel> {
  const SupportView({super.key});

  @override
  Widget builder(
      BuildContext context, SupportViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...List.generate(
            viewModel.supportOptions.length,
            (index) {
              final option = viewModel.supportOptions[index];
              return SupportOption(
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                subtitle: option['subtitle'] as String,
                onTap: option['action'] as VoidCallback,
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          const CompanyAddressSection(),
        ],
      ),
    );
  }

  @override
  SupportViewModel viewModelBuilder(BuildContext context) => SupportViewModel();
}