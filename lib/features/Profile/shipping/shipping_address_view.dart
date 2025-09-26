import 'package:easy_ph/features/Profile/shipping/shipping_address_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/data/models/profile.dart';
import '../../../ui/components/shimmers/shipping_address_shimmers.dart';

class ShippingAddressesPage extends StatelessWidget {
  const ShippingAddressesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ShippingAddressesViewModel>.reactive(
      viewModelBuilder: () => ShippingAddressesViewModel(),
      onModelReady: (viewModel) => viewModel.init(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shipping Addresses'),
          ),
          body: viewModel.isBusy
              ? const ShippingAddressesShimmer()
              : ListView.builder(
            itemCount: viewModel.shippingAddresses.length,
            itemBuilder: (context, index) {
              Address address = viewModel.shippingAddresses[index];
              return _buildAddressCard(context, viewModel, address, index);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.showAddAddressBottomSheet,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(BuildContext context, ShippingAddressesViewModel viewModel, Address address, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    address.address ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(context, Icons.edit, 'Edit', () {
                       viewModel.showEditAddressBottomSheet(address);
                    }),
                    _buildIconButton(context, Icons.delete, 'Delete', () {
                      viewModel.deleteAddress(index);
                    }),
                  ],
                ),
              ],
            ),
            Text(address.city ?? '', style: const TextStyle(fontSize: 18),),
            Text(address.state ?? '',style:  const TextStyle(fontSize: 18),),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label, [VoidCallback? onPressed]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}