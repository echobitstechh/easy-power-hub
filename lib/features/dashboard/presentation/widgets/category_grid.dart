import 'package:easy_ph/app/app.router.dart';
import 'package:easy_ph/features/dashboard/presentation/dashboad_view.dart';
import 'package:easy_ph/features/services/service_view.dart';
import 'package:easy_ph/features/shop/shop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../../app/app.locator.dart';
import '../../../../core/data/models/category.dart';
import '../dashboard_viewmodel.dart';

List<Widget> buildGridItems(BuildContext context, DashboardViewModel model) {
  List<Widget> tiles = [];

  final categories = {
    "solar": 'assets/images/solar.jpg',
    "electronics": 'assets/images/2148254069.jpg',
    "light": 'assets/images/107.jpg',
    "smart": 'assets/images/2148087576.jpg',
  };

  categories.forEach((key, imagePath) {
    final category = model.filteredCategories.firstWhere(
      (cat) => cat.name.toLowerCase().contains(key),
      orElse: () => Category(id: -1, name: '', status: CategoryStatus.active),
    );

    if (category.id != -1) {
      tiles.add(
        GestureDetector(
          onTap: () {
            final isSpecial = ['solar', 'electronics', 'light', 'smart'].contains(key);
            locator<NavigationService>().navigateToShopView(
              filter: category,
              isSpecialCategory: isSpecial,
            );
          },
          child: actionContainer(
            category.image?.isNotEmpty == true ? category.image! : imagePath,
            _getCategoryTitle(key, category.name),
            context
          ),
        ),
      );
    }
  });

  return tiles;
}

List<StaggeredGridTile> buildCardTiles(BuildContext context, DashboardViewModel model) {
  List<StaggeredGridTile> tiles = [];

  final categories = {
    "solar": 'assets/images/solar.jpg',
    "electronics": 'assets/images/2148254069.jpg',
    "light": 'assets/images/107.jpg',
    "smart": 'assets/images/2148087576.jpg',
  };

  categories.forEach((key, imagePath) {
    final category = model.filteredCategories.firstWhere(
      (cat) => cat.name.toLowerCase().contains(key),
      orElse: () => Category(id: -1, name: '', status: CategoryStatus.active),
    );

    if (category.id != -1) {
      tiles.add(StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (c) =>
                  ShopView(
                      filter: category
                  )
              ),
            );
          },
          child: SizedBox(
            height: 50,
            child: actionContainer(
              category.image?.isNotEmpty == true ? category.image! : imagePath,
              _getCategoryTitle(key, category.name),
              context
            ),
          ),
        ),
      ));
    }
  });

  return tiles;
}

String _getCategoryTitle(String key, String categoryName) {
  switch (key) {
    case 'light':
      return "LIGHTING AND FITTINGS";
    case 'smart':
      return "SMART HOMES";
    case 'solar':
      return "SOLAR";
    case 'electronics':
      return "ELECTRONICS";
    default:
      return categoryName.toUpperCase();
  }
}

Widget actionContainer(String imagePath, String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 0.0, right: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: imagePath.startsWith('http') 
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Title Text
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}