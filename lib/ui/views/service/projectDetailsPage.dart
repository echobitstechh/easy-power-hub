import 'dart:async';

import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/models/project.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import '../../../utils/donationPaymentModal.dart';
import '../../../utils/money_util.dart';
import '../../common/app_colors.dart';


class ProjectDetailsPage extends StatefulWidget {
  final ProjectResource project;

  const ProjectDetailsPage({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectDetailsPage> createState() => _ProjectdetalsState();
}

class _ProjectdetalsState extends State<ProjectDetailsPage> {

  final TextEditingController amountController = TextEditingController();
  Comment? replyingToComment;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.3,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom:
                          16.0), // Adjust padding to move title content closer to the bottom
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Members Count
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/partcipant_icon.png",
                            width: 44,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.project.members?.length ?? 0} Members',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Explore Button
                      InkWell(
                        onTap: () {
                          _launchProjectReel(
                              widget.project.project?.projectReel ?? '');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kcWhiteColor, // Capsule background color
                            borderRadius: BorderRadius.circular(
                                20), // Rounded capsule shape
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_circle,
                                size: 14, // Reduced icon size
                                color: kcSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Project Highlight",
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: const TextStyle(
                                    color: kcBlackColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          widget.project.project?.media?.first.url ??
                              'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient Overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black45, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(
                      8.0), // Add margin for better positioning
                  decoration: const BoxDecoration(
                    color: kcWhiteColor, // Black background for the icon
                    shape: BoxShape.circle, // Circular shape for the background
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: kcBlackColor), // White arrow
                    onPressed: () {
                      Navigator.pop(context); // Handle back navigation
                    },
                  ),
                ),
                actions: const [
                  // Container(
                  //   margin: const EdgeInsets.only(right: 16.0), // Align the share icon properly
                  //   decoration: BoxDecoration(
                  //     color: Colors.black.withOpacity(0.5), // Black background for the icon
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(Icons.share, color: Colors.white), // White share icon
                  //     onPressed: () {
                  //       _shareProject(context); // Handle sharing
                  //     },
                  //   ),
                  // ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.project?.projectTitle ?? '',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Project Description
                          Text(
                            widget.project.project?.projectDescription ?? '',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          if(widget.project.projectChecklist!.isNotEmpty)
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 0.0, left: 0.0, top: 10.0),
                                    child: SvgPicture.asset(
                                      "assets/images/benfits.svg",
                                      height: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, left: 10.0, top: 10.0),
                                    child: Text(
                                      'Project Goals',
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle:  TextStyle(
                                          fontSize: 16,
                                          color: uiMode.value == AppUiModes.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, left: 10.0, top: 10.0),
                                child: InkWell(
                                  onTap: () {
                                   _showProjectGoalsBottomSheet(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: kcSecondaryColor.withOpacity(
                                          0.2), // Capsule background color
                                      borderRadius: BorderRadius.circular(
                                          20), // Rounded capsule shape
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "See more",
                                          style: GoogleFonts.redHatDisplay(
                                            textStyle:  TextStyle(
                                              color:  uiMode.value == AppUiModes.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_circle_right,
                                          size: 16,
                                          color: kcSecondaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Project Goals List
                          _buildProjectGoalsList(2),
                          const SizedBox(height: 16),
                          // Comments Section Placeholder
                          // Comments Section
                          Row(
                            children: [
                              const Text(
                                "Comments",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              horizontalSpaceTiny,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(
                                      0.2), // Capsule background color
                                  borderRadius: BorderRadius.circular(
                                      4), // Rounded capsule shape
                                ),
                                child: Text(
                                  "${widget.project.recentComments?.length}",
                                  style: GoogleFonts.redHatDisplay(
                                    textStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          verticalSpaceSmall,
                          if (widget.project.recentComments!.isNotEmpty)
                            _buildCommentsSection(context, true),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ), // Comment Input Box at the Bottom
          Positioned(
            bottom: 0, // Stick to the bottom
            left: 0, // Align to the left
            right: 0, // Align to the right
            child: _buildCommentInputField(context),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0), // Adjust the bottom padding to move the FAB up
        child: FloatingActionButton(
          backgroundColor: Colors.transparent, // Set the button color
          onPressed: () {
            _showPaymentModal(context);
          },
          child: SvgPicture.asset(
            'assets/icons/dollar_pay.svg',
            height: 300,
            width: 300,
          ), // Button icon
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Place at the bottom right

    );
  }

  void _shareProject(BuildContext context) {
    final String shareText =
        "Help us raise funds for ${widget.project.project?.projectReel}. "
        "Join the effort and make an impact by donating to this great cause! Check it out here: https://yourprojectlink.com";

    //Share.share(shareText, subject: 'Donate to a Great Cause!');
  }

  Future<void> _launchProjectReel(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  //make comment section scrollable
  Widget _buildCommentsSection(BuildContext context, bool isFullComment) {
    List<Comment> recentComments = widget.project.recentComments ?? [];

    // Filter comments to get top-level comments (replyTo == null)
    List<Comment> topLevelComments = recentComments.where((comment) => comment.replyTo == null).toList();

    // Limit the number of top-level comments to 10
    int commentLimit = 10;
    List<Comment> limitedComments = topLevelComments.take(commentLimit).toList();

    return Container(
      color:  uiMode.value == AppUiModes.dark
          ? kcDarkGreyColor
          : Colors.grey[200],
      height: MediaQuery.of(context).size.height * 0.40,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount:  isFullComment
      ? limitedComments.length + 1 // Add 1 for "View all comments" button
          : limitedComments.length,
           // Add 1 for "View all comments" option
        itemBuilder: (context, index) {
          // Show the "View all comments" button after the 10th comment
          if (index == limitedComments.length && isFullComment) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _showFullComments(context); // Open modal to show all comments
                  },
                  child: const Text(
                    "View all comments",
                    style: TextStyle(
                      color: kcPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }

          final topLevelComment = limitedComments[index];

          // Find replies to this top-level comment
          List<Comment> replies = recentComments.where((comment) => comment.replyTo == topLevelComment.id).toList();


          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[400],
                      child: Text(
                        '${topLevelComment.user?.firstName?[0].toUpperCase() ?? ''}${topLevelComment.user?.lastName?[0].toUpperCase() ?? ''}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color:  uiMode.value == AppUiModes.dark
                              ? kcMediumGrey
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${topLevelComment.user?.firstName?.substring(0, 1).toUpperCase() ?? ''}${topLevelComment.user?.firstName?.substring(1).toLowerCase() ?? ''} '
                                        '${topLevelComment.user?.lastName?.substring(0, 1).toUpperCase() ?? ''}${topLevelComment.user?.lastName?.substring(1).toLowerCase() ?? ''}',
                                    style:  TextStyle(fontWeight: FontWeight.bold, color:  uiMode.value == AppUiModes.dark
                                        ? kcWhiteColor
                                        : Colors.grey[400],),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (value == 'Reply') {
                                      setState(() {
                                        replyingToComment = topLevelComment; // Set the reply target
                                      });
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return ['Reply'].map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(topLevelComment.comment ?? ''),
                            if (replies.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    topLevelComment.isExpanded = !topLevelComment.isExpanded;
                                  });
                                },
                                child: Text(
                                  topLevelComment.isExpanded ? 'Hide Replies' : 'View Replies (${replies.length})',
                                  style: const TextStyle(color: kcSecondaryColor, fontSize: 12),
                                ),
                              ),
                            if (topLevelComment.isExpanded)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: replies.length,
                                itemBuilder: (context, replyIndex) {
                                  final reply = replies[replyIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Text(
                                            '${reply.user?.firstName?[0].toUpperCase() ?? ''}${reply.user?.lastName?[0].toUpperCase() ?? ''}',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color:  uiMode.value == AppUiModes.dark
                                                  ? kcDarkGreyColor
                                                  : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(reply.comment ?? ''),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  // Bottom sheet to show all comments
  void _showFullComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "All Comments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _buildCommentsSection(context, false),
              ),
            ],
          ),
        );
      },
    );
  }

  // Comment input field pinned at the bottom
  Widget _buildCommentInputField(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color:  uiMode.value == AppUiModes.dark
            ? kcDarkGreyColor
            : Colors.grey[200], // Light grey background for the container
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20)), // Rounded edges
      ),
      child: Column(
        children: [
          if (replyingToComment != null) // Show "Replying to {name}" when replying
            Row(
              children: [
                Text(
                  'Replying to ${replyingToComment?.user?.firstName}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      replyingToComment = null; // Cancel the reply
                    });
                  },
                )
              ],
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Donate to join this Project, and make comments',
                    hintStyle: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        color: Color(0xFFCC9933),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ), // Padding inside the text field
                  ),
                ),
              ),
              // // Attach (link) button
              // IconButton(
              //   icon: const Icon(Icons.link, color: Colors.grey),
              //   onPressed: () {
              //     // Handle link click action
              //   },
              // ),
              // Send button
              InkWell(
                onTap: () {
                  final commentText = commentController.text;
                  if (commentText.isNotEmpty) {
                    if (replyingToComment != null) {
                      makeReplyComment(commentText, replyingToComment!); // Replying
                    } else {
                      makeComment(commentText); // New comment
                    }
                    replyingToComment = null;
                    commentController.clear();
                  }
                },
                child: SvgPicture.asset(
                  'assets/images/send-2.svg', // Replace with your SVG file path
                  color:  uiMode.value == AppUiModes.dark
                      ? kcMediumGrey
                      : kcDarkGreyColor, // Set the color for the icon
                  height: 25,
                  width: 25,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  // Display the first two project goals
  Widget _buildProjectGoalsList(int limit) {
    final projectGoals = widget.project.projectChecklist ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: projectGoals.take(limit).map((goal) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduce space between items
          child: Row(
            children: [
              Icon(
                goal.completed! ? Icons.check_circle : Icons.circle, // Icon for completed/uncompleted goal
                color: goal.completed! ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.name ?? '',
                  style: GoogleFonts.redHatDisplay(
                    textStyle: TextStyle(
                      color: goal.completed!
                          ? (uiMode.value == AppUiModes.dark ? Colors.white : Colors.black)
                          : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  void _showProjectGoalsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kcSecondaryColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child:
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                decoration: const BoxDecoration(
                  color: kcSecondaryColor, // Yellowish background
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    topLeft: Radius.circular(25.0),
                  ), // Adjusted border-radius only for the top
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 0.0, left: 0.0, top: 10.0),
                            child: SvgPicture.asset(
                              "assets/images/benfits.svg",
                              height: 20,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 10.0, left: 10.0, top: 10.0),
                            child: Text(
                              'Project Goals',
                              style: GoogleFonts.redHatDisplay(
                                textStyle: const TextStyle(
                                  color: kcBlackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor, // Set your desired background color
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    child: ListView.builder(
                      itemCount: widget.project.projectChecklist?.length ?? 0,
                      itemBuilder: (context, index) {
                        final goal = widget.project.projectChecklist![index];
                        return ListTile(
                          leading: Icon(
                            goal.completed! ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: goal.completed! ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            goal.name ?? '',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                //handle null value of completed goal
                                color: goal.completed! ? Colors.black : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )



              ),
            ],
          ),
        );
      },
    );
  }


  ValueNotifier<PaymentMethod> selectedPaymentMethod = ValueNotifier(PaymentMethod.wallet);
  ValueNotifier<bool> isPaymentProcessing = ValueNotifier(false);


  PaymentMethod get selectedMethod => selectedPaymentMethod.value;

  void selectMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  void _showPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ValueListenableBuilder<PaymentMethod>(
          valueListenable: selectedPaymentMethod,
          builder: (context, value, child) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: DonationsPaymentModalWidget(
                onPaymentMethodSelected: (PaymentMethod method) {
                  selectMethod(method);
                },
                onProceedWithPayment: () async {
                  checkoutDonation(context);
                },
                selectedPaymentMethod: selectedPaymentMethod.value,
                isPaymentProcessing: isPaymentProcessing,
                amountController: amountController,
              ),
            );
          },
        );
      },
    );
  }

  void checkoutDonation(BuildContext context) async {
    if (amountController.text.isEmpty) {
      locator<SnackbarService>().showSnackbar(
        message: 'Please insert an amount',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (double.tryParse(amountController.text) != null &&
        double.parse(amountController.text) < 10) {
      locator<SnackbarService>().showSnackbar(
        message: 'The donation amount must not be less than 10',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedPaymentMethod.value.name.isEmpty) {
      locator<SnackbarService>().showSnackbar(
        message: 'Please select a payment method',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isPaymentProcessing.value = true;

    try {
      ApiResponse res = await repo.donateToProject({
        "payment_method": selectedMethod.name,
        "project_id": widget.project.project?.id,
        "amount_donated": amountController.text,
      });

      if (res.statusCode == 201) {
        if (selectedPaymentMethod.value != PaymentMethod.wallet) {
          final String donationId = res.data['data']['donation']['id'];
          ApiResponse chargeResponse = await MoneyUtils().chargeCardUtil(
            selectedPaymentMethod.value,
            context,
            int.parse(amountController.text),
            donationId,
          );

          if (chargeResponse.statusCode != 200) {
            locator<SnackbarService>().showSnackbar(
              message: 'Payment failed. Please try again.',
              duration: const Duration(seconds: 3),
            );
            return;
          }
        }

        Navigator.pop(context); // Close the payment modal
        amountController.clear(); // Clear the input after successful payment

        // Show success modal with Lottie animation
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          barrierDismissible: true,
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/animations/payment_success.json"),
                        verticalSpaceMedium,
                        const Text(
                          "Donation Successful",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "You are a step closer to changing the world",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        locator<SnackbarService>().showSnackbar(
          message: res.data["message"],
          duration: const Duration(seconds: 3),
        );
        isPaymentProcessing.value = false;
      }
    } catch (e) {
      String errorMessage = e is DioError && e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] ?? 'An error occurred'
          : 'An error occurred during the donation process. Please try again.';

      locator<SnackbarService>().showSnackbar(
        message: errorMessage,
        duration: const Duration(seconds: 3),
      );
      isPaymentProcessing.value = false;
    } finally {
      // Stop processing (set to false)
      isPaymentProcessing.value = false;

      // Update user profile to reflect new account points
      try {
        ApiResponse res = await repo.getProfile();
        if (res.statusCode == 200) {
          profile.value = Profile.fromJson(Map<String, dynamic>.from(res.data['data']));
          await locator<LocalStorage>().save(LocalStorageDir.profileView, res.data["data"]);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  //write function to make new comment
  Future<void> makeComment(String comment) async {
    try {
      ApiResponse res = await repo.makeComment({
        "project": widget.project.project?.id,
        "comment": comment,
      });

      if (res.statusCode == 201) {
        locator<SnackbarService>().showSnackbar(
          message: 'Comment added successfully',
          duration: const Duration(seconds: 3),
        );


        setState(() {
          final newId = res.data['data']['_id'];

          final newComment = Comment(
            user: profile.value,
            comment: comment,
            createdAt: DateTime.now().toIso8601String(), // Current timestamp
            replyTo: null,
            id: newId,  // Assign temporary ID
          );
          widget.project.recentComments?.insert(0, newComment);
        });

      } else {
        locator<SnackbarService>().showSnackbar(
          message: res.data["message"],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: 'An error occurred while adding your comment. Please try again.',
        duration: const Duration(seconds: 3),
      );
    }
  }

  //write function to make reply comment
  Future<void> makeReplyComment(String comment, Comment replyingTo) async {
    try {
      ApiResponse res = await repo.makeComment({
        "project": widget.project.project?.id,
        "comment": comment,
        "replyTo": replyingTo.id,
      });

      if (res.statusCode == 201) {
        locator<SnackbarService>().showSnackbar(
          message: 'Reply added successfully',
          duration: const Duration(seconds: 3),
        );

        setState(() {
          final newId = res.data['data']['_id'];

          final newComment = Comment(
            user: profile.value,
            comment: comment,
            createdAt: DateTime.now().toIso8601String(), // Current timestamp
            replyTo: replyingTo.id,
            id: newId,  // Assign temporary ID
          );
          int parentCommentIndex = widget.project.recentComments?.indexWhere((c) => c.id == replyingTo.id) ?? -1;

          if (parentCommentIndex != -1) {
            widget.project.recentComments?.insert(parentCommentIndex + 1, newComment);
          }
        });


      } else {
        locator<SnackbarService>().showSnackbar(
          message: res.data["message"],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: 'An error occurred while adding your reply. Please try again.',
        duration: const Duration(seconds: 3),
      );
    }
  }

  String formatTimeAgo(String dateTimeString) {
    DateTime commentTime = DateTime.parse(dateTimeString);
    Duration difference = DateTime.now().difference(commentTime);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 7) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }


}