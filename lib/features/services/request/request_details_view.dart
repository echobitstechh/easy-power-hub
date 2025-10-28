import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/data/models/service_request.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';

class RequestDetailsBottomSheet extends StatelessWidget {
  final ServiceRequest serviceRequest;
  final VoidCallback? onCancelRequest;

  const RequestDetailsBottomSheet({
    Key? key,
    required this.serviceRequest,
    this.onCancelRequest,
  }) : super(key: key);

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '';
    DateTime dt;
    if (dateTime is DateTime) {
      dt = dateTime;
    } else if (dateTime is String) {
      try {
        dt = DateTime.parse(dateTime);
      } catch (_) {
        return dateTime;
      }
    } else {
      return dateTime.toString();
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  List<TimelineStep> _getTimelineSteps() {
    final status = serviceRequest.status.toLowerCase();
    final steps = <TimelineStep>[];

    steps.add(TimelineStep(
      title: 'Request Submitted',
      description: 'Your service request has been received',
      timestamp: _formatDateTime(serviceRequest.createdAt),
      isCompleted: true,
    ));

    if (status == 'cancelled') {
      steps.add(TimelineStep(
        title: 'Request Cancelled',
        description: serviceRequest.reason ?? 'You cancelled this service request',
        timestamp: _formatDateTime(serviceRequest.updatedAt),
        isCompleted: true,
        isError: true,
      ));
      return steps;
    } else if (status == 'declined') {
      steps.add(TimelineStep(
        title: 'Request Declined',
        description: serviceRequest.reason ?? 'Your service request was declined',
        timestamp: _formatDateTime(serviceRequest.updatedAt),
        isCompleted: true,
        isError: true,
      ));
      return steps;
    } else if (status == 'accepted') {
      steps.add(TimelineStep(
        title: 'Provider Assigned',
        description: serviceRequest.assignedPersonnel != null
            ? '${serviceRequest.assignedPersonnel!.name} has been assigned to your request'
            : 'Provider assigned to your request',
        timestamp: _formatDateTime(serviceRequest.updatedAt),
        isCompleted: true,
      ));

      steps.add(TimelineStep(
        title: 'Service In Progress',
        description: 'Service will be completed on scheduled date',
        timestamp: 'Scheduled: ${serviceRequest.date}, ${serviceRequest.time}',
        isCompleted: false,
      ));
    } else if (status == 'completed') {
      steps.add(TimelineStep(
        title: 'Provider Assigned',
        description: serviceRequest.assignedPersonnel != null
            ? '${serviceRequest.assignedPersonnel!.name} was assigned to your request'
            : 'Provider was assigned to your request',
        timestamp: 'Assigned',
        isCompleted: true,
      ));

      steps.add(TimelineStep(
        title: 'Service Completed',
        description: 'Service has been successfully completed',
        timestamp: _formatDateTime(serviceRequest.updatedAt),
        isCompleted: true,
      ));
    } else {
      steps.add(TimelineStep(
        title: 'Provider Assignment',
        description: 'Waiting for provider to be assigned',
        timestamp: 'Pending',
        isCompleted: false,
      ));

      steps.add(TimelineStep(
        title: 'Service Completion',
        description: 'Service completion pending',
        timestamp: 'Pending',
        isCompleted: false,
      ));
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final canCancel = serviceRequest.status.toLowerCase() == 'pending' ||
        serviceRequest.status.toLowerCase() == 'accepted';
    final timelineSteps = _getTimelineSteps();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Details',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  verticalSpaceTiny,
                  Text(
                    'Track your service request status',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  verticalSpaceMedium,

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                serviceRequest.serviceName,
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            horizontalSpaceSmall,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(serviceRequest.status),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                serviceRequest.status.toUpperCase(),
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpaceSmall,

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            horizontalSpaceTiny,
                            Text(
                              serviceRequest.date,
                              style: GoogleFonts.redHatDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            horizontalSpaceSmall,
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            horizontalSpaceTiny,
                            Text(
                              serviceRequest.time,
                              style: GoogleFonts.redHatDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpaceSmall,

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            horizontalSpaceTiny,
                            Expanded(
                              child: Text(
                                serviceRequest.address,
                                style: GoogleFonts.redHatDisplay(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (serviceRequest.description != null &&
                            serviceRequest.description!.isNotEmpty) ...[
                          verticalSpaceSmall,
                          Text(
                            'Description',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          verticalSpaceTiny,
                          Text(
                            serviceRequest.description!,
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],

                        if (serviceRequest.assignedPersonnel != null) ...[
                          verticalSpaceSmall,
                          Divider(color: Colors.grey[300]),
                          verticalSpaceSmall,
                          Text(
                            'Assigned Personnel',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          verticalSpaceTiny,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      serviceRequest.assignedPersonnel!.name,
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      serviceRequest.assignedPersonnel!.phone,
                                      style: GoogleFonts.redHatDisplay(
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    if (serviceRequest
                                        .assignedPersonnel!.email.isNotEmpty)
                                      Text(
                                        serviceRequest.assignedPersonnel!.email,
                                        style: GoogleFonts.redHatDisplay(
                                          textStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (serviceRequest.status.toLowerCase() == 'cancelled' &&
                            serviceRequest.reason != null &&
                            serviceRequest.reason!.isNotEmpty) ...[
                          verticalSpaceSmall,
                          Divider(color: Colors.grey[300]),
                          verticalSpaceSmall,
                          Text(
                            'Cancellation Reason',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                          verticalSpaceTiny,
                          Text(
                            serviceRequest.reason!,
                            style: GoogleFonts.redHatDisplay(
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  verticalSpaceSmall,

                  // Timeline Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Timeline',
                          style: GoogleFonts.redHatDisplay(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        ...List.generate(
                          timelineSteps.length,
                          (index) => _buildTimelineItem(
                            context: context,
                            step: timelineSteps[index],
                            isLast: index == timelineSteps.length - 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpaceMedium,

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.redHatDisplay(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (canCancel) ...[
                        horizontalSpaceSmall,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onCancelRequest?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Cancel Request',
                              style: GoogleFonts.redHatDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required TimelineStep step,
    required bool isLast,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? (step.isError ? Colors.red : Colors.orange)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.isCompleted
                    ? (step.isError ? Icons.close : Icons.check)
                    : Icons.circle,
                color: Colors.white,
                size: step.isCompleted ? 18 : 12,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: step.isCompleted
                    ? (step.isError ? Colors.red : Colors.orange)
                    : Colors.grey[300],
              ),
          ],
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.redHatDisplay(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted
                          ? (isDarkMode ? kcWhiteColor : kcBlackColor)
                          : Colors.grey[600],
                    ),
                  ),
                ),
                verticalSpaceTiny,
                Text(
                  step.description,
                  style: GoogleFonts.redHatDisplay(
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),
                verticalSpaceTiny,
                Text(
                  step.timestamp,
                  style: GoogleFonts.redHatDisplay(
                    textStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (!isLast) verticalSpaceSmall,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class TimelineStep {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;
  final bool isError;

  TimelineStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    this.isError = false,
  });
}