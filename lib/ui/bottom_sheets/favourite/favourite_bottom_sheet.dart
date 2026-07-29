import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../components/shimmers/favourite_shimmer.dart';
import 'favourite_bottomsheet_viewmodel.dart';
// import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
// import 'package:shimmer/shimmer.dart';
import '../../components/empty_state.dart';
import 'widgets/favourite_card.dart';

class FavoritesBottomSheet extends StatelessWidget {
  const FavoritesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FavoritesBottomSheetModel>.reactive(
      viewModelBuilder: () => FavoritesBottomSheetModel(),
      onViewModelReady: (viewModel) => viewModel.fetchFavorites(),
      builder: (context, viewModel, child) {
        if (viewModel.isBusy) {
          return const FavoritesShimmer();
        }

        if (viewModel.favorites.isEmpty) {
          return const Center(child: EmptyState(
            animation: "assets/animations/empty_cart.json",
            label: "No favorites yet",
          ));
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "My Favorites",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              verticalSpaceMedium,
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.favorites.length,
                  itemBuilder: (context, index) {
                    final fav = viewModel.favorites[index];
                    return FavouriteCard(
                      favoriteItem: fav,
                      viewModel: viewModel,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}