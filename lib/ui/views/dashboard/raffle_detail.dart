import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/models/raffle_cart_item.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/network/interceptors.dart';
import 'dashboard_viewmodel.dart';

class RaffleDetail extends StatefulWidget {
  final Raffle raffle;

  const RaffleDetail({
    required this.raffle,
    Key? key,
  }) : super(key: key);

  @override
  State<RaffleDetail> createState() => _RaffleDetailState();



}

class _RaffleDetailState extends State<RaffleDetail> {
  int quantity = 1;
  String activePic = "";
  List<Raffle> recommended = [];





  @override
  void initState() {

    setState(() {
      activePic =
          (widget.raffle == null)
              ? ""
              : widget.raffle.media?[0].location ?? "";
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.parse(widget.raffle.endDate ?? '');
    final now = DateTime.now();
    final remainingDuration = endDate.difference(now);

    return ViewModelBuilder<DashboardViewModel>.reactive(
      viewModelBuilder: () => DashboardViewModel(),
      builder: (context, viewModel, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // 90% of the screen's height
          minChildSize: 0.5, // Minimum size it can shrink to
          maxChildSize: 0.9, // Maximum size
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: uiMode.value == AppUiModes.dark
                  ? kcDarkGreyColor // Dark mode logo
                  : kcWhiteColor, // The background color of the sheet
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Top handle to indicate draggable sheet
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0, left: 5.0, top: 10.0),
                          child: Container(
                            width: double.infinity,
                            height: 370,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Image covering the entire card
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.raffle.media!.isNotEmpty == true
                                        ? widget.raffle.media![0].url!
                                        : 'https://via.placeholder.com/150',
                                    height: 350,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Tint overlay for better readability
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color:uiMode.value == AppUiModes.dark
                                        ? Colors.black.withOpacity(0.8)
                                        : Colors.black.withOpacity(0.6),
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
                                      widget.raffle.formattedTicketPrice ?? '',
                                      style: const TextStyle(
                                        color: kcPrimaryColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 14,
                                  left: 10,
                                  right: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Draw Happening',
                                            style: TextStyle(
                                              color: kcSecondaryColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SlideCountdown(
                                        duration: remainingDuration,
                                        decoration: const BoxDecoration(
                                          color: kcPrimaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        separator: ':',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        onDone: () {
                                          print('Countdown finished!');
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Image.asset("assets/images/partcipant_icon.png", width: 40,),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.raffle.participants?.length ?? 0} Participants',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // buildParticipantsAvatars(widget.raffle.participants ?? []),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                                child: Text(
                                  widget.raffle.name ?? '',
                                  style: GoogleFonts.redHatDisplay(
                                    textStyle:  TextStyle(
                                      fontSize: 24, // Custom font size
                                      fontWeight: FontWeight.bold,
                                      color:  uiMode.value == AppUiModes.dark
                                          ? kcWhiteColor // Dark mode logo
                                          : kcBlackColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                                child: Text(
                                  widget.raffle.description ?? '',
                                  style:
                                  GoogleFonts.redHatDisplay(
                                    textStyle:  TextStyle(
                                      color: uiMode.value == AppUiModes.dark
                                          ? kcWhiteColor // Dark mode logo
                                          : kcBlackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 0.0, left: 10.0, top: 10.0),
                                  child: SvgPicture.asset(
                                    "assets/images/benfits.svg",
                                    height: 20,
                                  ),
                                ),
                                 Padding(
                                  padding: EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                                  child: Text(
                                    'Extra Benefits',
                                    style: TextStyle(
                                      color: uiMode.value == AppUiModes.dark
                                          ? kcWhiteColor // Dark mode logo
                                          : kcBlackColor, // Ensure this color contrasts the background
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                              child: SvgPicture.asset(
                                "assets/images/InfoSquare.svg",
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0,10.0,0,16.0),
                          child: doMoreOnEasyph(context),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          padding: const EdgeInsets.all(12), // Add padding inside the container
                          decoration: BoxDecoration(
                            color: uiMode.value == AppUiModes.dark
                                ? kcDarkGreyColor // Dark mode logo
                                : kcWhiteColor, // Set the background color to white
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kcDarkGreyColor),// Round the corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1), // Shadow color
                                spreadRadius: 1, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'With Each Purchase Also get Afripoints which can be donated to great cause',
                                      style: TextStyle(
                                        fontSize: 13, // Size for the dollar amount
                                        color: uiMode.value == AppUiModes.light ? kcBlackColor : kcWhiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    //add to cart button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 55.0),
                      child: userLoggedIn.value == false
                          ? const SizedBox()
                          : ValueListenableBuilder<List<CartItem>>(
                          valueListenable: cart,
                          builder: (context, value, child) {
                            bool isInCart = value.any((item) =>
                            item.product?.id == widget.raffle.id);
                            CartItem? cartItem = isInCart
                                ? value.firstWhere((item) =>
                            item.product?.id == widget.raffle.id)
                                : null;

                            return isInCart && cartItem != null
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: kcVeryLightGrey,
                                  borderRadius:
                                  BorderRadius.circular(9)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      locator<NavigationService>()
                                          .navigateToCartView();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: kcSecondaryColor,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Goto Cart",
                                            style: TextStyle(
                                                color: kcPrimaryColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 53,
                                    decoration: BoxDecoration(
                                      color: kcWhiteColor,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child:  Row(
                                      children: [
                                        InkWell(
                                          // onTap: () => viewModel
                                          //     .decreaseRaffleQuantity(cartItem),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: kcWhiteColor,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                                child: Icon(Icons.remove,
                                                    size: 18,
                                                    color: kcBlackColor)),
                                          ),
                                        ),
                                        horizontalSpaceSmall,
                                        Text(
                                          "${cartItem.quantity}",
                                          style: const TextStyle(
                                              color: kcBlackColor),
                                        ),
                                        horizontalSpaceSmall,
                                        InkWell(
                                          // onTap: () => viewModel
                                          //     .increaseRaffleQuantity(cartItem),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: kcWhiteColor,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: const Align(
                                                alignment: Alignment.center,
                                                child: Icon(Icons.add,
                                                    size: 18,
                                                    color: kcBlackColor)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            )
                                : InkWell(
                              onTap: () async {
                                // RaffleCartItem newItem = RaffleCartItem(
                                //     raffle: widget.raffle,
                                //     quantity: 1);
                                // viewModel.addToRaffleCart(widget.raffle);
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: kcSecondaryColor,
                                  borderRadius:
                                  BorderRadius.circular(9),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Add Raffle to cart",
                                      style: TextStyle(
                                          color: kcPrimaryColor),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      color: kcPrimaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    verticalSpaceSmall
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget doMoreOnEasyph(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          height: 80, // You can adjust the height as necessary
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  locator<NavigationService>().navigateToWallet();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: uiMode.value == AppUiModes.dark
                          ? Color(0xFF2E2E2E)
                          : Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: uiMode.value == AppUiModes.dark
                              ? Colors.transparent
                              : kcLightGrey,
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    // Added padding around the content of the container
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Colored Circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: kcSecondaryColor, // Customize the color
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8), // Space between the circle and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Instant Wallet Credit",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    fontSize: 14, // Custom font size
                                    fontWeight: FontWeight.bold, // Custom font weight
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.white
                                        : Colors.black, // Custom text color
                                  ),
                                ),
                              ),
                              verticalSpaceTiny,
                              Text(
                                'Value equal to the ticket\'s value!',
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    fontSize: 10,
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Second GestureDetector for Donate to Non-profits
              GestureDetector(
                onTap: () {
                  // locator<NavigationService>().navigateToNotificationView();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: uiMode.value == AppUiModes.dark
                          ? Color(0xFF2E2E2E)
                          : Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: uiMode.value == AppUiModes.dark
                              ? Colors.transparent
                              : kcLightGrey,
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: kcSecondaryColor, // Customize the color
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8), // Space between the circle and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Donate to Non-profits",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    fontSize: 14, // Custom font size
                                    fontWeight: FontWeight.bold, // Custom font weight
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                  ),
                                ),
                              ),
                              verticalSpaceTiny,
                              Text(
                                'Supported by our partners',
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: TextStyle(
                                    fontSize: 10,
                                    color: uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : kcBlackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildParticipantsAvatars(List<Participant> participants) {
    double avatarSize = 20.0;
    double overlapOffset = 15.0; // Adjust the overlap amount

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Constrain the Stack with a specific width
        SizedBox(
          height: avatarSize,
          width: participants.length * overlapOffset + avatarSize, // Ensure a finite width
          child: Stack(
            children: participants.asMap().entries.map((entry) {
              int index = entry.key;
              Participant participant = entry.value;

              return Positioned(
                left: index * overlapOffset,
                child: ClipOval(
                  child: participant.profilePic?.url != null
                      ? Image.network(
                    participant.profilePic!.url!,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                  )
                      : _buildInitialsCircle(participant),
                ),
              );
            }).toList(),
          ),
        ),
        Text(
          ' ${participants.length} Participants',
          style: GoogleFonts.redHatDisplay(
            fontSize: 10,
            color: uiMode.value == AppUiModes.dark
                ? kcWhiteColor // Dark mode logo
                : kcBlackColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsCircle(Participant participant) {
    String initials = _getInitials(participant);
    return CircleAvatar(
      radius: 12, // Adjust the size if needed
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

}



