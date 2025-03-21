// // import 'package:easyph/ui/common/app_colors.dart';
// // import 'package:easyph/ui/common/ui_helpers.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// //
// // class Receipt extends StatefulWidget {
// //   final Map<String, dynamic> info;
// //   final int totalAmount;
// //
// //   const Receipt({
// //     required this.info,
// //     required this.totalAmount,
// //     Key? key,
// //   }) : super(key: key);
// //
// //   @override
// //   State<Receipt> createState() => _ReceiptState();
// // }
// //
// // class _ReceiptState extends State<Receipt> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: ListView(
// //         children: [
// //           Stack(
// //             children: [
// //               Container(
// //                 height: MediaQuery.of(context).size.height - 180,
// //                 width: MediaQuery.of(context).size.width,
// //                 color: kcWhiteColor,
// //               ),
// //               Positioned(
// //                 left: 0,
// //                 right: 0,
// //                 top: 80,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(50),
// //                   height: 600,
// //                   decoration: const BoxDecoration(
// //                     color: kcWhiteColor,
// //                     image: DecorationImage(
// //                       fit: BoxFit.cover,
// //                       image: AssetImage(
// //                         "assets/images/reciept_bg.png",
// //                       ),
// //                     ),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       verticalSpaceSmall,
// //                       const Text(
// //                         "Payment Success!",
// //                         style: TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: kcWhiteColor),
// //                       ),
// //                       verticalSpaceSmall,
// //                       Text(
// //                         "Your payment has been successfully done.",
// //                         style: TextStyle(color: kcWhiteColor.withOpacity(0.72)),
// //                       ),
// //                       verticalSpaceSmall,
// //                       Divider(
// //                         color: kcWhiteColor.withOpacity(0.16),
// //                         thickness: 1,
// //                       ),
// //                       verticalSpaceSmall,
// //                       Text(
// //                         "Total Payment",
// //                         style: TextStyle(color: kcWhiteColor.withOpacity(0.72)),
// //                       ),
// //                       verticalSpaceSmall,
// //                       Text(
// //                         "N${widget.totalAmount}",
// //                         style: const TextStyle(
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                             color: kcWhiteColor),
// //                       ),
// //                       verticalSpaceMedium,
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.all(10),
// //                               decoration: BoxDecoration(
// //                                 border: Border.all(
// //                                   color: kcWhiteColor.withOpacity(0.16),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     "Draw ticket Number",
// //                                     style: TextStyle(
// //                                         color: kcWhiteColor.withOpacity(0.72),
// //                                         fontSize: 12),
// //                                   ),
// //                                   Text(
// //                                     "${widget.info["user"]["order"][0]["tracking"]["tracking_number"]}",
// //                                     style: const TextStyle(
// //                                         color: kcWhiteColor, fontSize: 12),
// //                                   )
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           horizontalSpaceSmall,
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.all(10),
// //                               decoration: BoxDecoration(
// //                                 border: Border.all(
// //                                   color: kcWhiteColor.withOpacity(0.16),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     "Payment Time",
// //                                     style: TextStyle(
// //                                         color: kcWhiteColor.withOpacity(0.72),
// //                                         fontSize: 12),
// //                                   ),
// //                                   Text(
// //                                     DateFormat("d MMM y, h:m").format(
// //                                         DateTime.parse(
// //                                             widget.info["transaction"][0]
// //                                                 ["created"])),
// //                                     //"25 Feb 2023, 13:22",
// //                                     style: const TextStyle(
// //                                         color: kcWhiteColor, fontSize: 12),
// //                                   )
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       verticalSpaceSmall,
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.all(10),
// //                               decoration: BoxDecoration(
// //                                 border: Border.all(
// //                                   color: kcWhiteColor.withOpacity(0.16),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     "Payment Method",
// //                                     style: TextStyle(
// //                                         color: kcWhiteColor.withOpacity(0.72),
// //                                         fontSize: 12),
// //                                   ),
// //                                   const Text(
// //                                     "Wallet",
// //                                     style: TextStyle(
// //                                         color: kcWhiteColor, fontSize: 12),
// //                                   )
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           horizontalSpaceSmall,
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.all(10),
// //                               decoration: BoxDecoration(
// //                                 border: Border.all(
// //                                   color: kcWhiteColor.withOpacity(0.16),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     "Sender Name",
// //                                     style: TextStyle(
// //                                         color: kcWhiteColor.withOpacity(0.72),
// //                                         fontSize: 12),
// //                                   ),
// //                                   Text(
// //                                     // "",
// //                                     "${widget.info["user"]["firstname"]} ${widget.info["user"]["lastname"]}",
// //                                     style: const TextStyle(
// //                                         color: kcWhiteColor, fontSize: 12),
// //                                   )
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       verticalSpaceLarge,
// //                       Image.asset("assets/images/easyph_light.png")
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               Positioned(
// //                 left: 0,
// //                 right: 0,
// //                 top: 60,
// //                 child: Container(
// //                   height: 70,
// //                   width: 70,
// //                   decoration: BoxDecoration(
// //                       color: const Color(0xFF25282E),
// //                       shape: BoxShape.circle,
// //                       boxShadow: [
// //                         BoxShadow(
// //                             offset: const Offset(0, 5.96),
// //                             blurRadius: 15.9,
// //                             color: const Color(0xFF000000).withOpacity(0.16))
// //                       ]),
// //                   child: Center(
// //                     child: Container(
// //                       height: 40,
// //                       width: 40,
// //                       decoration: const BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: kcSecondaryColor,
// //                       ),
// //                       child: const Center(
// //                         child: Icon(
// //                           Icons.check,
// //                           color: kcBlackColor,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               )
// //             ],
// //           ),
// //           verticalSpaceSmall,
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: const [
// //               Icon(Icons.download),
// //               horizontalSpaceSmall,
// //               Text("Get PDF Receipt"),
// //             ],
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               Navigator.pop(context);
// //             },
// //             child: const Text("Close"),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class Receipt extends StatefulWidget {
//   final Map<String, dynamic> info;
//   final int totalAmount;
//
//   const Receipt({
//     required this.info,
//     required this.totalAmount,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<Receipt> createState() => _ReceiptState();
// }
//
// class _ReceiptState extends State<Receipt> {
//   @override
//   Widget build(BuildContext context) {
//     // Example data structure, replace with actual data
//     final List<Map<String, dynamic>> orderItems = [
//       {
//         'name': 'Nike Woven Tracksuit X Force',
//         'quantity': 1,
//         'price': 'N45,089.90',
//       },
//       // Add other items...
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Receipt'),
//         centerTitle: true,
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Header section with the date and status indicator
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       DateFormat('EEEE, d MMMM').format(DateTime.now()), // Replace with actual date
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Chip(
//                       label: Text('Successful'),
//                       backgroundColor: Colors.green,
//                     ),
//                   ],
//                 ),
//                 // Banner thanking for the purchase
//                 Container(
//                   margin: EdgeInsets.symmetric(vertical: 16.0),
//                   padding: EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.circular(4.0),
//                   ),
//                   child: Image.asset(
//                     "assets/images/receipt_header.png",
//                     height: 80, // Adjust the height to make the image smaller
//                     fit: BoxFit.fitHeight,
//                   ),
//                 ),
//                 // Order Summary Header
//                 ListTile(
//                   title: Text(
//                     'ORDER SUMMARY',
//                     style: TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 // Order Items List
//                 ...orderItems.map((item) => ListTile(
//                   leading: Icon(Icons.shopping_bag), // Replace with actual image
//                   title: Text(item['name']),
//                   subtitle: Text('x${item['quantity']}'),
//                   trailing: Text(item['price']),
//                 )),
//                 Divider(),
//                 // Total Order
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Total Order'),
//                     Text('N150,000'), // Replace with actual data
//                   ],
//                 ),
//                 SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Delivery Charge:'),
//                     Text('N2,000'), // Replace with actual data
//                   ],
//                 ),
//                 Divider(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('TOTAL:'),
//                     Text('N152,000', style: TextStyle(fontWeight: FontWeight.bold)), // Replace with actual data
//                   ],
//                 ),
//                 SizedBox(height: 24),
//                 // Delivery Address
//                 ListTile(
//                   title: Text('DELIVERY ADDRESS'),
//                   subtitle: Text('No. 12 location road off so-so Road.'), // Replace with actual data
//                 ),
//                 Divider(),
//                 // Draw Tickets Section
//                 ListTile(
//                   title: Text('Your Draw Tickets'),
//                   trailing: Icon(Icons.chevron_right), // Replace with actual icon if needed
//                 ),
//                 // Example of a ticket, repeat as needed
//                 Card(
//                   child: ListTile(
//                     leading: Image.asset('assets/images/macbook.png'), // Replace with actual image
//                     title: Text('Win Macbook Pro 2020'),
//                     subtitle: Text('Draw Date: 26th Nov.'),
//                     trailing: Chip(
//                       label: Text('Active'),
//                       backgroundColor: Colors.green,
//                     ),
//                   ),
//                 ),
//                 Divider(),
//                 // Ticket Number
//                 Text('Ticket No: 1234567890999876'), // Replace with actual data
//                 // Add more tickets if necessary
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


// import 'package:easyph/app/app.router.dart';
// import 'package:easyph/core/data/models/raffle_ticket.dart';
//
// import '../../../core/data/models/order_item.dart';
//
// class Receipt {
//   Transaction receipt;
//   List<RaffleTicket> tickets;
//
//   Receipt({List<dynamic>});
//
//   factory Receipt.fromJson(Map<String, dynamic> json) {
//     return  json['receipt'];
//   }
// }

