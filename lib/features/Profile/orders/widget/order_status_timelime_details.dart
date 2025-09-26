import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../ui/common/app_colors.dart';
import '../order_viewmodel.dart';

List<Map<String, dynamic>> getTimelineSteps(OrderStatus currentStatus) {
  // ... (your existing getTimelineSteps function)
  final allSteps = [
    {'status': OrderStatus.Pending, 'title': 'Order Placed', 'description': 'We have received your order'},
    {'status': OrderStatus.Processing, 'title': 'Order Confirmed', 'description': 'We have confirmed your order'},
    {'status': OrderStatus.Delivered, 'title': 'Order Delivered', 'description': 'We have shipped your order'},
    {'status': OrderStatus.Cancelled, 'title': 'Order Cancelled', 'description': 'Your order has been cancelled'},
  ];

  final filteredSteps = allSteps
      .where((step) => step['status'] != OrderStatus.Returns)
      .toList();

  final currentIndex = filteredSteps.indexWhere((step) => step['status'] == currentStatus);

  for (int i = 0; i < filteredSteps.length; i++) {
    filteredSteps[i]['isFirst'] = (i == 0);
    filteredSteps[i]['isLast'] = (i == filteredSteps.length - 1);
    filteredSteps[i]['isCompleted'] = (i < currentIndex);
    filteredSteps[i]['isActive'] = (i == currentIndex);
  }

  return filteredSteps;
}


class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final ScrollController scrollController;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final timelineEntries = getTimelineSteps(currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Order Status",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: timelineEntries.length,
              itemBuilder: (context, index) {
                final entry = timelineEntries[index];
                final bool isFirst = entry['isFirst'] as bool;
                final bool isLast = entry['isLast'] as bool;
                final bool isCompleted = entry['isCompleted'] as bool;
                final bool isActive = entry['isActive'] as bool;

                return TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: isFirst,
                  isLast: isLast,
                  indicatorStyle: IndicatorStyle(
                    width: 25,
                    color: isActive
                        ? kcPrimaryColor
                        : isCompleted
                        ? kcPrimaryColor
                        : kcVeryLightGrey,
                    iconStyle: isCompleted || isActive
                        ?  IconStyle(
                      iconData: Icons.check,
                      color: kcWhiteColor,
                    )
                        : null,
                  ),
                  beforeLineStyle: LineStyle(
                    color: isCompleted ? kcPrimaryColor : kcVeryLightGrey,
                    thickness: 3,
                  ),
                  afterLineStyle:
                  LineStyle(color: isCompleted ? kcPrimaryColor : kcVeryLightGrey, thickness: 3),
                  endChild: _buildTimelineCard(
                    title: entry['title'] as String,
                    description: entry['description'] as String,
                    isActive: isActive,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String description,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? kcPrimaryColor : Colors.grey[300]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? kcWhiteColor : Colors.white, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? kcWhiteColor : kcBlackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: isActive ? kcWhiteColor : kcBlackColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}