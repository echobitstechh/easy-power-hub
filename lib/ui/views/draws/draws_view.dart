import 'package:easyph/core/utils/config.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/models/raffle_ticket.dart';
import '../../../state.dart';
import '../dashboard/raffle_detail.dart';
import '../home/module_switch.dart';
import 'draws_viewmodel.dart';
import 'empty_tab_content.dart';

class DrawsView extends StatelessWidget {
  const DrawsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ViewModelBuilder<DrawsViewModel>.reactive(
        viewModelBuilder: () => DrawsViewModel(),
        onModelReady: (viewModel) {
          viewModel.init();
        },
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: kcSecondaryColor,
          appBar: AppBar(
            backgroundColor: kcSecondaryColor,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(25.0),
            //         topRight: Radius.circular(25.0),
            //         bottomLeft: Radius.circular(25.0),
            //         bottomRight: Radius.circular(25.0)
            //     )
            // ),
            toolbarHeight: 100.0,
            title: Center(
              child: Container(
                padding:
                    const EdgeInsets.only(left: 7, right: 7, bottom: 7, top: 7),
                decoration: BoxDecoration(
                  color: uiMode.value == AppUiModes.dark
                      ? kcWhiteColor.withOpacity(0.7)
                      : kcWhiteColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kcSecondaryColor, width: 0),
                ),
                child: Builder(
                  builder: (context) {
                    final TabController tabController =
                        DefaultTabController.of(context);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Draws Button
                        buildOption(
                          context: context,
                          text: 'Draws',
                          icon: 'ticket_star.svg',
                          isSelected: tabController.index ==
                              0, // Selected if on the first tab
                          onTap: () {
                            viewModel.togglePage(
                                true); // Updates the view model state
                            tabController
                                .animateTo(0); // Switch to the first tab
                            viewModel.notifyListeners(); // Rebuild on tap
                          },
                        ),
                        // Winners Button
                        buildOption(
                          context: context,
                          text: 'Winners',
                          icon: 'star.svg',
                          isSelected: tabController.index ==
                              1, // Selected if on the second tab
                          onTap: () {
                            tabController
                                .animateTo(1); // Switch to the second tab
                            viewModel.notifyListeners(); // Rebuild on tap
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
              color: uiMode.value == AppUiModes.dark
                  ? kcDarkGreyColor
                  : kcWhiteColor, // Set your desired background color
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
              child: TabBarView(
                children: [
                  // First Tab: Draws
                  RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.refreshData();
                    },
                    child: viewModel.isBusy && viewModel.raffleList.isEmpty
                        ? ListView.builder(
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return _buildShimmerCard(); // Shimmer while loading
                            },
                          )
                        : viewModel.raffleList.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  EmptyTabContent(
                                    title:
                                        'No raffles are sold out at the moment.',
                                    description: '',
                                    rules: [
                                      'Entry Eligibility: Secure your spot in the draw with an Easyph card purchase of \$5...',
                                    ],
                                  )
                                ],
                              )
                            : Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Added horizontal margin
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        onChanged: viewModel.updateSearchQuery,
                                        decoration: InputDecoration(
                                          hintText: 'Search',
                                          prefixIcon: const Icon(Icons.search),
                                          filled: true,
                                          fillColor: uiMode.value == AppUiModes.dark
                                              ? kcMediumGrey
                                              : Colors.grey[200],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    verticalSpaceSmall,
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount:
                                            viewModel.filteredRaffle.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  25.0)),
                                                ),
                                                // barrierColor: Colors.black.withAlpha(50),
                                                // backgroundColor: Colors.transparent,
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.7),
                                                builder:
                                                    (BuildContext context) {
                                                  return FractionallySizedBox(
                                                    heightFactor:
                                                        0.9, // 70% of the screen's height
                                                    child: RaffleDetail(
                                                        raffle: viewModel
                                                                .filteredRaffle[
                                                            index]),
                                                  );
                                                },
                                              );
                                            },
                                            child: _buildRaffleCard(
                                                viewModel.filteredRaffle[index],
                                                viewModel,
                                                index),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                  // Second Tab: Winners
                  RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.refreshData();
                    },
                    child: viewModel.isBusy && viewModel.raffleWinnerList.isEmpty
                        ? ListView.builder(
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return _buildShimmerCard(); // Shimmer for loading
                            },
                          )
                        : viewModel.raffleWinnerList.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  EmptyTabContent(
                                    title: 'No winners at the moment.',
                                    description: '',
                                    rules: [
                                      'Entry Eligibility: Secure your spot in the draw...',
                                    ],
                                  ),
                                ],
                              )
                            : Container(
                                color: uiMode.value == AppUiModes.dark
                                    ? kcDarkGreyColor
                                    : kcWhiteColor,
                                margin: const EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Added horizontal margin
                                child: Column(
                                  children: <Widget>[
                                    verticalSpaceMedium,
                                    liveDrawsWidget(
                                        context, viewModel.raffleDrawEvents),
                                    verticalSpaceSmall,
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Easyph Raffle Draw Winners",
                                            style:
                                                GoogleFonts.bricolageGrotesque(
                                              textStyle:  TextStyle(
                                                fontSize:
                                                    16, // Custom font size
                                                fontWeight: FontWeight
                                                    .w700, // Custom font weight
                                                color: uiMode.value == AppUiModes.dark ? kcLightGrey : kcBlackColor, // Custom text color (optional)
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    verticalSpaceSmall,
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount:
                                            viewModel.raffleWinnerList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return _buildWinnerCard(
                                              viewModel.raffleWinnerList[index],
                                              viewModel,
                                              index);
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOption({
    required BuildContext context,
    required String text,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color:(uiMode.value == AppUiModes.dark && isSelected)
              ? kcDarkGreyColor
              : Colors.transparent, // Interior color remains transparent
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? kcSecondaryColor : Colors.transparent,
            width: 2.0, // Set the width as needed
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
              color: isSelected ? kcSecondaryColor : kcLightGrey,
              height: 20,
            ),
            // Icon(icon, color: isSelected ? kcSecondaryColor : kcPrimaryColor),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
                  color: (uiMode.value == AppUiModes.dark && isSelected)
                      ? kcWhiteColor
                      : kcLightGrey,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Panchang",
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawsCard extends StatelessWidget {
  final Raffle raffle;
  final DrawsViewModel viewModel;
  final Winner? winner;
  final int index;
  final bool isWinner;

  const DrawsCard({
    required this.raffle,
    super.key,
    required this.viewModel,
    required this.index,
    required this.isWinner,
    this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      // height: 400,
      decoration: BoxDecoration(
        color: uiMode.value == AppUiModes.light ? kcWhiteColor : kcBlackColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kcSecondaryColor),
        boxShadow: [
          BoxShadow(
            color: kcBlackColor.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 4,
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 0.0),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0, // Make the loader thinner
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  kcSecondaryColor), // Change the loader color
                            ),
                          ),
                          imageUrl: raffle.media?.first.location ??
                              'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          height: 182,
                          width: double.infinity,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fadeInDuration: const Duration(milliseconds: 500),
                          fadeOutDuration: const Duration(milliseconds: 300),
                        ),
                        Container(
                          // width: screenWidth, // Set the width to the screen width
                          height: 40.0,
                          color:
                              kcSecondaryColor, // Set the background color to blue
                          padding: const EdgeInsets.all(7.0),
                          child: Marquee(
                            text: !isWinner
                                ? 'SOLD OUT SOLD OUT SOLD OUT'
                                : 'WINNER WINNER WINNER WINNER', // Your text here
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                fontFamily: "Panchang"),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 20.0,
                            velocity: 100.0,
                            pauseAfterRound: const Duration(milliseconds: 50),
                            startPadding: 10.0,
                            accelerationDuration: const Duration(seconds: 2),
                            accelerationCurve: Curves.linear,
                            decelerationDuration:
                                const Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          ),
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isWinner)
                      Text(
                        'Win!!!',
                        style: TextStyle(
                            fontSize: 22,
                            color: uiMode.value == AppUiModes.light
                                ? kcSecondaryColor
                                : kcWhiteColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Panchang"),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (!isWinner)
                      Text(
                        raffle.name ?? 'Product Name',
                        style: TextStyle(
                            fontSize: 20,
                            color: uiMode.value == AppUiModes.light
                                ? kcPrimaryColor
                                : kcSecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Panchang"),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isWinner)
                      Text(
                        '${winner?.user?.firstName} ${winner?.user?.lastName}' ??
                            'Product Name',
                        style: TextStyle(
                            fontSize: 20,
                            color: uiMode.value == AppUiModes.light
                                ? kcPrimaryColor
                                : kcSecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Panchang"),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300]?.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (raffle == null)
                                      ? ""
                                      : "Draw Date: ${DateFormat("d MMM").format(DateTime.parse(raffle.endDate ?? DateTime.now().toIso8601String()))}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () async {
                                  const url = AppConfig.youtubeOfficial;
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/youtube.svg',
                                    height: 20, // Icon size
                                  ),
                                ),
                              ),
                              horizontalSpaceTiny,
                              InkWell(
                                onTap: () async {
                                  const url = AppConfig.instagramOfficial;
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/instagram.svg',
                                    height: 20, // Icon size
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    if (!isWinner)
                      const Text(
                        'Raffle dates subject to change. Follow us on s'
                        'ocial media for updates and live draw events. '
                        'Your big win awaits!',
                        style: TextStyle(fontSize: 10),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget liveDrawsWidget(BuildContext context, List<DrawEvent> drawEvents) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Previous Live Draws",
        style: GoogleFonts.bricolageGrotesque(
          textStyle:  TextStyle(
            fontSize: 15, // Custom font size
            fontWeight: FontWeight.bold, // Custom font weight
            color: uiMode.value == AppUiModes.dark ? kcLightGrey : kcBlackColor, // Custom text color (optional)
          ),
        ),
      ),
      verticalSpaceMedium,
      Container(
        height: 104, // Adjust height according to your design
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: drawEvents.length,
          itemBuilder: (context, index) {
            final event = drawEvents[index];
            return GestureDetector(
              onTap: () async {
                final Uri uri = Uri.parse(event.link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  print('Could not launch ${event.link}');
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    width: 80, // Adjust width according to your design
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            event.media.isNotEmpty
                                ? event.media[0].url!
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            DateFormat('dd MMM, yyyy h:mm a').format(
                                DateTime.parse(event.raffle.endDate ??
                                    DateTime.now().toString())),
                            style: GoogleFonts.redHatDisplay(
                              textStyle: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Helper method to build a shimmer card
Widget _buildShimmerCard() {
  return Shimmer.fromColors(
    baseColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!,
    highlightColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[300]!
        : Colors.grey[100]!,
    child: Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: uiMode.value == AppUiModes.dark
            ? Colors.grey[700]!
            : Colors.grey[300]!,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget _buildRaffleCard(Raffle raffle, DrawsViewModel viewModel, int index) {
  return Container(
    width: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            viewModel.filteredRaffle[index].media?.first.url ??
                'https://via.placeholder.com/150',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Tint overlay for better readability
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color:
                Colors.black.withOpacity(0.6), // Dark semi-transparent overlay
            height: double.infinity,
            width: double.infinity,
          ),
        ),
        // Raffle details positioned on top of the image
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kcWhiteColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              viewModel.filteredRaffle[index].formattedTicketPrice ?? '',
              style: const TextStyle(
                  color: kcPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'roboto'),
            ),
          ),
        ),
        Positioned(
          top: 33,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kcSecondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Ticket Price',
              style: TextStyle(
                fontSize: 7,
                color: kcPrimaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'WIN Prize in ${viewModel.filteredRaffle[index].endDate != null && viewModel.filteredRaffle[index].endDate!.isNotEmpty ? DateFormat('yyyy-MM-dd').format(DateTime.tryParse(viewModel.filteredRaffle[index].endDate!) ?? DateTime.now()) : 'Invalid Date'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                viewModel.filteredRaffle[index].name ?? '',
                style: const TextStyle(
                  color: kcSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              buildParticipantsAvatars(viewModel.filteredRaffle[index].participants ??
                  []), // Show participants' avatars
              // Row(
              //   children: [
              //     Image.asset(
              //       "assets/images/partcipant_icon.png",
              //       width: 35,
              //     ),
              //     const SizedBox(width: 4),
              //     Text(
              //       '${viewModel.filteredRaffle[index].participants?.length ?? 0} Participants',
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 10,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildWinnerCard(Winner winner, DrawsViewModel viewModel, int index) {
  return Container(
    width: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            viewModel.raffleWinnerList[index].raffle?.media?.first.url ??
                'https://via.placeholder.com/150',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Tint overlay for better readability
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color:
                Colors.black.withOpacity(0.6), // Dark semi-transparent overlay
            height: double.infinity,
            width: double.infinity,
          ),
        ),
        // Raffle details positioned on top of the image

        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kcSecondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.white,
                ),
                Text('Draw completed',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 9,
                        color: kcBlackColor,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 35,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kcSecondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('WINNER',
                style: GoogleFonts.redHatDisplay(
                  textStyle:  TextStyle(
                    fontSize: 9,
                    color: kcBlackColor,
                    fontWeight: FontWeight.w400,
                  ),
                )),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kcWhiteColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                    '${viewModel.raffleWinnerList[index].user?.firstName?.substring(0, 1).toUpperCase() ?? ''}${viewModel.raffleWinnerList[index].user?.firstName?.substring(1).toLowerCase() ?? ''} ${viewModel.raffleWinnerList[index].user?.lastName?.substring(0, 1).toUpperCase() ?? ''}${viewModel.raffleWinnerList[index].user?.lastName?.substring(1).toLowerCase() ?? ''}',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: kcBlackColor,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildParticipantsAvatars(List<Participant> participants) {
  return SizedBox(
    height: 20, // Adjust the size to match the avatar size
    child: Stack(
      children: participants.asMap().entries.map((entry) {
        int index = entry.key;
        Participant participant = entry.value;
        double overlapOffset = 17.0; // Control the overlap amount
        return Positioned(
          left: index * overlapOffset,
          child: participant.profilePic?.url != null
              ? ClipOval(
            child: Image.network(
              participant.profilePic!.url!,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
          )
              : _buildInitialsCircle(participant), // Show initials if no image
        );
      }).toList(),
    ),
  );
}

Widget _buildInitialsCircle(Participant participant) {
  String initials = _getInitials(participant);
  return CircleAvatar(
    radius: 10, // Adjust the size if needed
    backgroundColor: kcSecondaryColor, // Customize background color
    child: Text(
      initials,
      style: const TextStyle(
        color: Colors.white, // Text color for initials
        fontSize: 12, // Adjust the font size if needed
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String _getInitials(Participant participant) {
  String firstName = participant.firstname?.isNotEmpty == true ? participant.firstname! : '';
  String lastName = participant.lastname?.isNotEmpty == true ? participant.lastname! : '';
  return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
}


