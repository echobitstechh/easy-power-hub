import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/product-search/search_view.dart';


class ProductSearchBar extends StatelessWidget {
  final DashboardViewModel viewModel;
  
  const ProductSearchBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchScreen(), // Remove viewModel parameter
            ),
          );
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[600]! 
                  : Colors.grey,
              width: 1.0,
            ),
          ),
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.search, color: Colors.grey),
              ),
              Text(
                'Search product...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}