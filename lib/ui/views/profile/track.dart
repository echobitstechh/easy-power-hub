// import 'package:easyph/app/app.locator.dart';
// import 'package:easyph/core/data/models/order_item.dart';
// import 'package:easyph/core/data/repositories/repository.dart';
// import 'package:easyph/ui/common/ui_helpers.dart';
// import 'package:easyph/ui/components/submit_button.dart';
// import 'package:easyph/ui/components/text_field_widget.dart';
// import 'package:awesome_rating/awesome_rating.dart';
// import 'package:casa_vertical_stepper/casa_vertical_stepper.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:stacked_services/stacked_services.dart';
//
// import '../../../core/network/api_response.dart';
// import '../../../utils/order_util.dart';
// import '../../common/app_colors.dart';
//
// // REJECTED=0,
// // PENDING=1,
// // PROCESSING=2,
// // APPROVED=3,
// // SHIPPED=4,
// // DELIVERED=5,
// // RECEIVED=6,
// // INTRANSIT=7,
//
// class Track extends StatefulWidget {
//   // final OrderItem item;
//
//   const Track({required this.item, Key? key}) : super(key: key);
//
//   @override
//   State<Track> createState() => _TrackState();
// }
//
// class _TrackState extends State<Track> {
//   double rating = 0;
//   bool loading = false;
//   final comment = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           "Tracking",
//           style: TextStyle(color: kcBlackColor),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           Card(
//             margin: const EdgeInsets.all(8),
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Container(
//                         height: 80,
//                         width: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: kcVeryLightGrey,
//                           image: widget.item.product?.pictures == null ||
//                                   widget.item.product!.pictures!.isEmpty
//                               ? null
//                               : DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: NetworkImage(widget
//                                       .item.product!.pictures![0].location!),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${widget.item.product?.productName}',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             const SizedBox(height: 4),
//                             Text("Order ID: ${widget.item.id}",
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.grey)),
//                             const SizedBox(height: 4),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             "Quantity: ${widget.item.quantity}",
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           Text(
//                             "On ${DateFormat("d MMM").format(DateTime.parse(widget.item.created!))}",
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 4),
//                           OrderUtil.statusChip(widget.item.status!),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           verticalSpaceLarge,
//           const Text(
//             "Estimated delivery date",
//             style: TextStyle(fontSize: 18),
//           ),
//            Text(
//             DateFormat("d MMM y").format(DateTime.parse(widget.item.tracking!.updated!)),
//             style: const TextStyle(fontSize: 18),
//           ),
//           verticalSpaceMedium,
//           CasaVerticalStepperView(
//             steps: buildSteps(),
//           ),
//           verticalSpaceMedium,
//           // CasaVerticalStepperView(steps: [
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //         color: widget.item.status == 1 ? kcOrangeColor : kcMediumGrey,
//           //         shape: BoxShape.circle,
//           //       ),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.edit_note,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order Pending",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("We have received your order"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 40,
//           //     ),
//           //   ),
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //               widget.item.status == 2 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.edit_note,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order Processing",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("We have received your order"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 40,
//           //     ),
//           //   ),
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //               widget.item.status == 3 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.card_giftcard,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Approved",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("Your order is approved"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 40,
//           //     ),
//           //   ),
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //               widget.item.status == 4 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.card_giftcard,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order Shipped",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("Your order has been shipped"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 40,
//           //     ),
//           //   ),
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //               widget.item.status == 5 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.fire_truck,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order delivered",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("Your order is out for delivery"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 40,
//           //     ),
//           //   ),
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //               widget.item.status == 6 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.check,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order Received",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("Your order has received"),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 0,
//           //     ),
//           //   ),
//           //
//           //   StepperStep(
//           //     leading: Container(
//           //       height: 40,
//           //       width: 40,
//           //       decoration: BoxDecoration(
//           //           color:
//           //           widget.item.status == 6 ? kcOrangeColor : kcMediumGrey,
//           //           shape: BoxShape.circle),
//           //       child: const Center(
//           //         child: Icon(
//           //           Icons.cancel_outlined,
//           //           color: Colors.red,
//           //         ),
//           //       ),
//           //     ),
//           //     title: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: const [
//           //         Text(
//           //           "Order Rejected",
//           //           style: TextStyle(
//           //             fontSize: 16,
//           //             fontWeight: FontWeight.bold,
//           //             color: kcMediumGrey,
//           //           ),
//           //         ),
//           //         Text("Your order has rejected,"),
//           //         Text("contact support."),
//           //       ],
//           //     ),
//           //     view: Container(
//           //       height: 0,
//           //     ),
//           //   ),
//           // ]),
//           verticalSpaceMedium,
//           widget.item.status! >= 6
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Add review"),
//                     verticalSpaceMedium,
//                     TextFieldWidget(
//                       hint: "Enter Comment",
//                       controller: comment,
//                     ),
//                     verticalSpaceSmall,
//                     Row(
//                       children: [
//                         const Text("Choose rating"),
//                         horizontalSpaceMedium,
//                         AwesomeStarRating(
//                           starCount: 5,
//                           rating: rating,
//                           size: 30.0,
//                           onRatingChanged: (double value) {
//                             setState(() {
//                               rating = value;
//                             });
//                           },
//                           color: Colors.orange,
//                           borderColor: Colors.orange,
//                         ),
//                       ],
//                     ),
//                     verticalSpaceMedium,
//                     SubmitButton(
//                       isLoading: loading,
//                       label: "Rate",
//                       submit: () async {
//                         setState(() {
//                           loading = true;
//                         });
//
//                         try {
//                           ApiResponse res = await locator<Repository>()
//                               .reviewOrder({
//                             "orderId": widget.item.id,
//                             "comment": comment.text,
//                             "rating": rating.toInt()
//                           });
//                           if (res.statusCode == 200) {
//                             locator<SnackbarService>()
//                                 .showSnackbar(message: res.data["message"]);
//                             Navigator.pop(context);
//                           }
//                         } catch (e) {
//                          throw Exception(e);
//                         }
//
//                         setState(() {
//                           loading = false;
//                         });
//                       },
//                       color: kcPrimaryColor,
//                     )
//                   ],
//                 )
//               : const SizedBox()
//         ],
//       ),
//     );
//   }
//
//
//   List<StepperStep> buildSteps() {
//     int currentStatus = widget.item.status!;  // This is an int representing the status.
//
//     // Define a utility method to map the integer status to the enum.
//     OrderStatus getOrderStatusFromInt(int status) {
//       return OrderStatus.values.firstWhere(
//             (e) => e.index == status,
//         orElse: () => OrderStatus.PENDING, // Default case or error handling if status is out of range
//       );
//     }
//
//
//     OrderStatus activeStatus = getOrderStatusFromInt(currentStatus);
//
//     List<StepperStep> steps = OrderStatus.values.map((status) {
//       bool isActive = status == activeStatus;
//       IconData icon = Icons.error; // Default icon
//       String title = "Unknown Status"; // Default title
//       String subtitle = "Status is not recognized.";
//
//
//       switch (status) {
//         // case OrderStatus.REJECTED:
//         //   icon = Icons.cancel_outlined;
//         //   title = "Order Rejected";
//         //   subtitle = "Rejected, please contact support.";
//         //   break;
//         case OrderStatus.PENDING:
//           icon = Icons.hourglass_empty;
//           title = "Order Pending";
//           subtitle = "We have received your order.";
//           break;
//         case OrderStatus.PROCESSING:
//           icon = Icons.settings;
//           title = "Order Processing";
//           subtitle = "Your order is being processed.";
//           break;
//         case OrderStatus.SHIPPED:
//           icon = Icons.local_shipping_outlined;
//           title = "Order Shipped";
//           subtitle = "Your package has been shipped.";
//           break;
//         case OrderStatus.INTRANSIT:
//           icon = Icons.check_circle_outline;
//           title = "Order In Transit";
//           subtitle = "Your order is on its way.";
//           break;
//         case OrderStatus.DELIVERED:
//           icon = Icons.done_all;
//           title = "Order Delivered";
//           subtitle = "Your order has been delivered.";
//           break;
//         case OrderStatus.RECEIVED:
//           icon = Icons.check_circle_outline;
//           title = "Order Received";
//           subtitle = "You have received your order.";
//           break;
//
//
//         default:
//         // Handling for default case if required
//           break;
//       }
//
//       return StepperStep(
//         leading: buildStepIcon(icon, isActive),
//         title: buildStepTitle(title, subtitle, isActive),
//         view: Container(height: 40),
//       );
//     }).toList();
//
//     return steps;
//   }
//
//   // List<StepperStep> buildSteps() {
//   //   int currentStatus = widget.item.status!;  // This is an int representing the status.
//   //   List<StepperStep> steps = [];
//   //
//   //   // Iterate over the OrderStatus enum to create a step for each status.
//   //   for (var status in OrderStatus.values) {
//   //     IconData icon;
//   //     String title;
//   //     String subtitle;
//   //
//   //     switch (status) {
//   //       case OrderStatus.REJECTED:
//   //         icon = Icons.cancel_outlined;
//   //         title = "Order Rejected";
//   //         subtitle = "order rejected, contact support.";
//   //         break;
//   //       case OrderStatus.PENDING:
//   //         icon = Icons.hourglass_empty;
//   //         title = "Order Pending";
//   //         subtitle = "We have received your order.";
//   //         break;
//   //       case OrderStatus.PROCESSING:
//   //         icon = Icons.settings;
//   //         title = "Order Processing";
//   //         subtitle = "Your order is being processed.";
//   //         break;
//   //       case OrderStatus.APPROVED:
//   //         icon = Icons.thumb_up;
//   //         title = "Order Approved";
//   //         subtitle = "Your order has been approved.";
//   //         break;
//   //       case OrderStatus.SHIPPED:
//   //         icon = Icons.local_shipping;
//   //         title = "Order Shipped";
//   //         subtitle = "Your order has been shipped.";
//   //         break;
//   //       case OrderStatus.DELIVERED:
//   //         icon = Icons.done_all;
//   //         title = "Order Delivered";
//   //         subtitle = "Your order has been delivered.";
//   //         break;
//   //       case OrderStatus.RECEIVED:
//   //         icon = Icons.check_circle_outline;
//   //         title = "Order Received";
//   //         subtitle = "You have received your order.";
//   //         break;
//   //       case OrderStatus.INTRANSIT:
//   //         icon = Icons.airplanemode_active;
//   //         title = "Order In Transit";
//   //         subtitle = "Your order is on its way.";
//   //         break;
//   //       default:
//   //         continue;
//   //     }
//   //
//   //     StepperStep step = StepperStep(
//   //       leading: buildStepIcon(icon, currentStatus == status.index),
//   //       title: buildStepTitle(title, subtitle, currentStatus == status.index),
//   //       view: Container(height: 40),
//   //     );
//   //
//   //     steps.add(step);
//   //   }
//   //
//   //   return steps;
//   // }
//
//   Container buildStepIcon(IconData icon, bool isActive) {
//     return Container(
//       height: 40,
//       width: 40,
//       decoration: BoxDecoration(
//         color: isActive ? kcOrangeColor : kcMediumGrey,
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Icon(icon, color: Colors.white),
//       ),
//     );
//   }
//
//
//   Column buildStepTitle(String title, String subtitle, bool isActive) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: isActive ? kcOrangeColor : kcMediumGrey,
//           ),
//         ),
//         Text(subtitle),
//       ],
//     );
//   }
// }
