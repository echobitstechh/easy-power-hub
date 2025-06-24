import 'dart:ui';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/core/data/models/profile.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:easyph/core/data/models/profile.dart' as pro;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/transaction.dart';
import '../../../state.dart';
import '../../../utils/depositPaymentModal.dart';
import '../../../utils/withdrawalPaymentModal.dart';
import '../../components/empty_state.dart';
import 'package:intl/intl.dart';

import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';


class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late pro.Wallet wallet = pro.Wallet(balance: 0);

  bool loading = false;

  bool loadingProfile = true;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _amountNumberController = TextEditingController();
  String? selectedBundle;
  final TextEditingController amountController = TextEditingController();

  List<Transaction> transactions = [];

  Map<String, List<Transaction>> groupedTransactions = {};

  @override
  void initState() {
    getProfile();

    getHistory();

    super.initState();
  }

  void getHistory() async {
    setState(() {
      loading = true;
    });

    try {
      ApiResponse res = await locator<Repository>().getTransactions();

      if (res.statusCode == 200) {
        setState(() {
          transactions = (res.data['data']['items'] as List)
              .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          groupRidesByMonth();
        });
      }
    } catch (e) {
      throw Exception("Error Api call");
    }

    setState(() {
      loading = false;
    });
  }

  void groupRidesByMonth() {
    setState(() {
      groupedTransactions.clear();

      for (var transaction in transactions) {
        String monthYear = transaction.createdAt != null
            ? DateFormat('MMMM yyyy')
                .format(DateTime.parse(transaction.createdAt!))
            : 'Unknown Date';

        if (groupedTransactions.containsKey(monthYear)) {
          groupedTransactions[monthYear]!.add(transaction);
        } else {
          groupedTransactions[monthYear] = [transaction];
        }
      }
    });
  }

  Future<void> getProfile() async {
    ApiResponse res = await locator<Repository>().getProfile();

    setState(() {
      loadingProfile = false;

      if (res.statusCode == 200) {
        Map<String, dynamic> userData =
            res.data["data"] as Map<String, dynamic>;

        profile.value = Profile.fromJson(userData);
      } else {
        wallet = pro.Wallet(balance: 0);

        locator<SnackbarService>().showSnackbar(message: res.data["message"]);
      }
    });
  }

  @override


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Wallet(under development)", style: TextStyle(color: Colors.red),),
      ),
      body: Stack(
        children: [
          // Your existing content
          RefreshIndicator(
            onRefresh: () async {
              getProfile();
            },
            child: ListView(
              children: [
                Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 500,
                                    child: const Image(
                                      image: AssetImage('assets/images/Frame.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Installment: 100,000.00',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Balance: 100,000.00',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Pending: 40,000.00',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showPaymentModal(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: kcPrimaryColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                'assets/images/send-2.svg',
                                color: kcPrimaryColor,
                                height: 17,
                                width: 17,
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                'Deposit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kcBlackColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kcPrimaryColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _showWithdrawalModal(context);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/send-2.svg',
                                color: kcPrimaryColor,
                                height: 17,
                                width: 17,
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                'Withdraw',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kcBlackColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        verticalSpaceTiny,
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: SegmentedTabControl(
                            splashColor: Colors.transparent,
                            indicatorDecoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: kcPrimaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            tabTextColor: Colors.black,
                            selectedTabTextColor: Colors.black,
                            tabs: [
                              SegmentTab(
                                backgroundColor: Colors.transparent,
                                label: 'Installment',
                              ),
                              SegmentTab(
                                backgroundColor: Colors.transparent,
                                label: 'Airtime & Data',
                              ),
                              SegmentTab(
                                backgroundColor: Colors.transparent,
                                label: 'Payment record',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 800,
                          child: TabBarView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Your existing tab content here...
                              // I'm keeping your original content but shortened for brevity
                              RefreshIndicator(
                                onRefresh: () async {
                                  // await viewModel.refreshData();
                                },
                                child: loading
                                    ? Padding(
                                  padding: const EdgeInsets.all(26.0),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                    : transactions.isEmpty
                                    ? const EmptyState(
                                  animation: "no_transactions.json",
                                  label: "No Installment Yet",
                                )
                                    : ListView.builder(
                                  itemCount: groupedTransactions.keys.length,
                                  itemBuilder: (context, index) {
                                    // Your existing list builder content
                                    return Container(); // Placeholder
                                  },
                                ),
                              ),
                              // Second tab content
                              Container(),
                              // Third tab content
                              Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Card(
                      elevation: 20,
                      shadowColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kcPrimaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.construction,
                                size: 50,
                                color: kcPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Coming Soon Text
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: kcPrimaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle
                            Text(
                              'This feature is under development and will be available soon.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Loading indicator
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kcPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: DepositsPaymentModalWidget(
                onPaymentMethodSelected: (PaymentMethod method) {
                  selectMethod(method);
                },
                onProceedWithPayment: () async {
                  //checkoutDonation(context);
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
  void _showWithdrawalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ValueListenableBuilder<PaymentMethod>(
          valueListenable: selectedPaymentMethod,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: WithdrawalPaymentModalWidget(
                onProceedWithPayment: () async {
                  //checkoutDonation(context);
                },
                isPaymentProcessing: isPaymentProcessing,
              ),
            );
          },
        );
      },
    );
  }

}
