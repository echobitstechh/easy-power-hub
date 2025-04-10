import 'package:easyph/state.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/utils/date_time_utils.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../utils/cart_utill.dart';
import '../../../widget/custom_clipper.dart';
import '../../common/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../service/service_view.dart';
import '../service/service_view.dart';





/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class RaffleReceiptPage extends StatelessWidget {
  final List<CartItem> carts;

  const RaffleReceiptPage({Key? key, required this.carts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: <Widget>[
          //       ElevatedButton(
          //         onPressed: () {
          //           createAndSharePdf();
          //         },
          //         style: ElevatedButton.styleFrom(
          //           foregroundColor: uiMode.value == AppUiModes.dark
          //               ? kcDarkGreyColor
          //               : kcWhiteColor, // Text and icon color based on theme
          //           backgroundColor: uiMode.value == AppUiModes.dark
          //               ? kcDarkGreyColor
          //               : kcWhiteColor, // Background color based on theme
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //         ),
          //         child: const Row(
          //           children: [
          //             Icon(Icons.share_outlined, size: 10.0),
          //             SizedBox(width: 4), // This replaces horizontalSpaceTiny
          //             Text('Share Receipt', style: TextStyle(fontSize: 15)),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SingleChildScrollView(
            // Use SingleChildScrollView for a single child scrollable widget
            child: ClipPath(
              clipper: MyClipper(),
              child: Card(
                color: uiMode.value == AppUiModes.dark
                    ? kcDarkGreyColor
                    : kcWhiteColor,
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 8.0, vertical: 4.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     crossAxisAlignment: CrossAxisAlignment.end,
                      //     children: <Widget>[
                      //       ElevatedButton(
                      //         onPressed: () {
                      //           createAndSharePdf();
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           foregroundColor: uiMode.value == AppUiModes.dark
                      //               ? kcWhiteColor
                      //               : kcDarkGreyColor,
                      //           backgroundColor: uiMode.value == AppUiModes.dark
                      //               ? kcDarkGreyColor
                      //               : kcWhiteColor,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //         child: const Row(
                      //           children: [
                      //             Icon(
                      //               Icons.share_outlined,
                      //               size: 20.0,
                      //             ),
                      //             horizontalSpaceTiny,
                      //             Text('Share Receipt',
                      //                 style: TextStyle(fontSize: 15)),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      verticalSpaceMedium,

                      Card(
                        margin: const EdgeInsets.all(0.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: uiMode.value == AppUiModes.dark
                                ? kcDarkGreyColor
                                : kcWhiteColor, // Card's background color
                            borderRadius: BorderRadius.circular(
                                10.0), // Ensure this matches the card's border radius
                            boxShadow: const [
                              BoxShadow(
                                color: kcSecondaryColor,
                                blurRadius: 0,
                                spreadRadius: 1,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: <Widget>[
                                verticalSpaceLarge,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDate(DateTime.now()),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: uiMode.value == AppUiModes.dark
                                              ? kcWhiteColor
                                              : kcBlackColor,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    const Row(
                                      children: [
                                        Icon(Icons.ac_unit,
                                            size: 15, color: Colors.green),
                                        Text('Successful',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green)),
                                      ],
                                    )
                                  ],
                                ),
                                // Container(
                                //   margin: const EdgeInsets.symmetric(
                                //       vertical: 16.0),
                                //   decoration: BoxDecoration(
                                //     color: kcPrimaryColor,
                                //     borderRadius: BorderRadius.circular(10.0),
                                //   ),
                                //   child: Image.asset(
                                //     "assets/images/receipt_header.png",
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                                Row(
                                  children: [
                                    Text(
                                      'TICKET SUMMARY',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: uiMode.value == AppUiModes.dark
                                            ? kcWhiteColor
                                            : kcBlackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpaceTiny,
                                ...carts.map((cartItem) => ListTile(
                                      leading: Image.network(
                                          (cartItem.product?.images != null &&
                                                  cartItem.product!.images!
                                                      .isNotEmpty)
                                              ? cartItem.product!.images![0]
                                              : 'https://via.placeholder.com/120',
                                          height: 44,
                                          width:
                                              48), // Replace with your image URL field
                                      title: Text(
                                          cartItem.product!.productName!,
                                          style:
                                              const TextStyle(fontSize: 10.61)),
                                      subtitle: Text('${cartItem.quantity}',
                                          style:
                                              const TextStyle(fontSize: 10.61)),
                                      trailing: Text(
                                          MoneyUtils().formatAmount(
                                              double.parse(cartItem
                                                      .product!.salePrice!)
                                                  .toInt()),
                                          style: TextStyle(
                                            fontSize: 10.61,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                uiMode.value == AppUiModes.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontFamily: "satoshi",
                                          )),
                                    )),
                                const Divider(),
                                verticalSpaceMedium,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Order',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100),
                                    ),
                                    Text(
                                      MoneyUtils().formatAmount(
                                          getRaffleSubTotal(carts).toInt()),
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: uiMode.value == AppUiModes.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: "satoshi",
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpaceSmall,
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TOTAL:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100),
                                    ),
                                    Text(
                                      MoneyUtils().formatAmount(
                                          getRaffleSubTotal(carts).toInt()),
                                      style: const TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.3),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                verticalSpaceSmall,
                                SvgPicture.asset(
                                  uiMode.value == AppUiModes.dark
                                      ? "assets/images/easy_power_logo.svg" // Dark mode logo
                                      : "assets/images/easy_power_logo.svg",
                                  width: 150,
                                  height: 40,
                                ),
                                verticalSpaceSmall
                              ],
                            ),
                          ),
                        ),
                      )

                      // Text(
                      //   profile.value.shipping?.firstWhere((element) => element.isDefault!).shippingAddress ?? "Default shipping not set",
                      //   style: const TextStyle(color: kcSecondaryColor),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      for (var item in cart.value) {
                        await repo.deleteFromCart(item.product!.id.toString());
                      }
                      cart.value.clear();
                    } catch (e) {
                      print(e);
                    }
                    await locator<LocalStorage>().delete(LocalStorageDir.cart);
                    cart.notifyListeners();

                    locator<NavigationService>().clearStackAndShow(Routes.homeView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: uiMode.value == AppUiModes.dark
                        ? kcDarkGreyColor
                        : kcWhiteColor,
                    foregroundColor: uiMode.value == AppUiModes.dark
                        ? kcWhiteColor
                        : kcDarkGreyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Back Home',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Need help setting up or installing your product?\nYou can request a professional installer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      for (var item in cart.value) {
                        await repo.deleteFromCart(item.product!.id.toString());
                      }
                      cart.value.clear();
                    } catch (e) {
                      print(e);
                    }
                    await locator<LocalStorage>().delete(LocalStorageDir.cart);
                    cart.notifyListeners();

                    locator<NavigationService>().clearStackAndShow(Routes.homeView);

                    Future.delayed(const Duration(milliseconds: 100), () {
                      locator<NavigationService>().navigateTo(Routes.ServicesView);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcSecondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Request Installation Service',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createAndSharePdf() async {
    final pdf = pw.Document();

    final imageBytes =
        await rootBundle.load('assets/images/receipt_header.png');
    final image = pw.MemoryImage(
      imageBytes.buffer.asUint8List(),
    );
    List<Future<pw.Widget>> cartItemFutures =
        carts.map((cartItem) => createCartItemWidget(cartItem)).toList();

    List<pw.Widget> cartItemWidgets = await Future.wait(cartItemFutures);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    formatDate(DateTime.now()),
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.normal),
                  ),
                  pw.Row(
                    children: [
                      pw.Text('Successful',
                          style: const pw.TextStyle(
                              fontSize: 11, color: PdfColor(0, 1, 0))),
                    ],
                  )
                ],
              ),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 16.0),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(10.0),
                ),
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
              pw.Text(
                'TICKET SUMMARY',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),

              pw.Column(
                children: cartItemWidgets,
              ),

              pw.Divider(),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Order',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                  ),
                  pw.Text(
                    MoneyUtils().formatAmount(getRaffleSubTotal(carts).toInt()),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                  ),
                  pw.Text(
                    MoneyUtils().formatAmount(getRaffleSubTotal(carts).toInt()),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14.3),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              // pw.Text(
              //   profile.value.shipping?.firstWhere((element) => element.isDefault!).shippingAddress ?? "Default shipping not set",
              // ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    Share.shareFiles([file.path], text: 'Your receipt');
  }

  Future<pw.Widget> createCartItemWidget(CartItem cartItem) async {
    // Attempt to load the image from the network
    final response = await http.get(Uri.parse(cartItem.product!.images!.first));

    pw.Widget imageWidget;
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      final image = pw.MemoryImage(imageBytes);
      imageWidget =
          pw.Image(image, width: 44, height: 48); // Use the loaded image
    } else {
      print('Failed to load network image.');
      imageWidget =
          pw.Text('Image not available'); // Use a placeholder or error widget
    }

    // Construct the container with the image widget
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 44,
            height: 48,
            margin: const pw.EdgeInsets.only(right: 8.0),
            child: imageWidget, // Use the image widget here
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(cartItem.product!.productName!,
                    style: const pw.TextStyle(fontSize: 10.61)),
                pw.Text('${cartItem.quantity}',
                    style: const pw.TextStyle(fontSize: 10.61)),
              ],
            ),
          ),
          pw.Text(
            '₦${MoneyUtils().formatAmount(double.parse(cartItem.product!.salePrice!).toInt())}',
            style:
                pw.TextStyle(fontSize: 10.61, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<pw.Widget> createNetworkImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final image = pw.MemoryImage(imageBytes);
        return pw.Image(image, width: 44, height: 48);
      } else {
        print('Failed to load network image.');
        // Return a placeholder widget or handle the error as you see fit
        return pw.Text('Image not available');
      }
    } catch (e) {
      print('Error loading image: $e');
      // Handle exception by returning a placeholder or an error widget
      return pw.Text('Image load error');
    }
  }
}
