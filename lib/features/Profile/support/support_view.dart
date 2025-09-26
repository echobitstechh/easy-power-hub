
import 'package:easy_ph/features/Profile/support/shipping_viewmodel.dart';
import 'package:easy_ph/features/Profile/support/widget/support_option.dart';
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: viewModel.supportOptions.length,
        itemBuilder: (context, index) {
          final option = viewModel.supportOptions[index];
          // The fix: Pass a simple VoidCallback to onTap
          return SupportOption(
            icon: option['icon'] as IconData,
            title: option['title'] as String,
            subtitle: option['subtitle'] as String,
            onTap: option['action'] as VoidCallback,
          );
        },
      ),
    );
  }

  @override
  SupportViewModel viewModelBuilder(BuildContext context) => SupportViewModel();
}