import 'package:easyph/state.dart';
import 'package:flutter/material.dart';
import 'package:easyph/core/data/models/transaction.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/components/empty_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FullTransactionsPage extends StatefulWidget {
  @override
  _FullTransactionsPageState createState() => _FullTransactionsPageState();
}

class _FullTransactionsPageState extends State<FullTransactionsPage> {
  List<Transaction> transactions = [];
  bool loading = false;
  bool loadingMore = false;
  int currentPage = 1;
  int totalPages = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTransactions();

    // Listen to scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !loadingMore &&
          currentPage < totalPages) {
        print('ready to load more');
        loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the controller
    super.dispose();
  }

  Future<void> fetchTransactions({int page = 1}) async {
    setState(() {
      loading = true;
    });

    try {
      ApiResponse res = await Repository().getTransactions(page: page);
      if (res.statusCode == 200) {
        final data = res.data['data']['items'] as List;
        final meta = res.data['data']['meta'];

        setState(() {
          // Check if we are loading more, if so, append new data to the existing list
          if (page > 1) {
            transactions.addAll(data.map((e) => Transaction.fromJson(e)).toList());
          } else {
            transactions = data.map((e) => Transaction.fromJson(e)).toList();
          }
          currentPage = meta['page'];
          totalPages = meta['total_pages']; // Ensure correct pagination metadata
        });
      }
    } catch (e) {
      // Handle error
      print('Error fetching transactions: $e');
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> loadMoreTransactions() async {
    if (currentPage < totalPages) {
      setState(() {
        loadingMore = true;
      });
      await fetchTransactions(page: currentPage + 1);
      setState(() {
        loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            transactions.clear();
            currentPage = 1;
          });
          await fetchTransactions();
        },
        child: loading
            ? Center(child: CircularProgressIndicator())
            : transactions.isEmpty
            ? const EmptyState(
          animation: "no_transactions.json",
          label: "No Transactions Found",
        )
            : ListView.builder(
          controller: _scrollController, // Assign the controller here
          itemCount: transactions.length + (loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == transactions.length) {
              // Display loader at the bottom when loading more
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final transaction = transactions[index];

            return ListTile(
              leading: SvgPicture.asset(
                'assets/icons/ticket_out.svg',
                height: 28,
              ),
              title: Text(
                transaction.paymentType == 'raffle'
                    ? 'Ticket Purchase'
                    : 'Donation',
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              subtitle: Text(
                DateFormat('EEEE, d MMM hh:mm a').format(
                  DateTime.parse(transaction.createdAt!),
                ),
                style: GoogleFonts.redHatDisplay(
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: uiMode.value == AppUiModes.dark
                        ? kcMediumGrey
                        : kcDarkGreyColor,
                  ),
                ),
              ),
              trailing: Text(
                '${transaction.amount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}