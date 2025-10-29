import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_ph/core/utils/status_util.dart';
import '../../../ui/common/ui_helpers.dart';

class ServiceRequestItem extends StatelessWidget {
  final String serviceName;
  final String status;
  final String date;
  final String time;
  final String address;
  final String? description;
  final String? assignedPersonName;
  final String? assignedPersonPhone;
  final String? assignedPersonEmail;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancelRequest;

  const ServiceRequestItem({
    Key? key,
    required this.serviceName,
    required this.status,
    required this.date,
    required this.time,
    required this.address,
    this.description,
    this.assignedPersonName,
    this.assignedPersonPhone,
    this.assignedPersonEmail,
    this.onViewDetails,
    this.onCancelRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtil.getStatusColor(status);
    final canCancel = StatusUtil.canCancel(status);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                  serviceName,
                  style: GoogleFonts.redHatDisplay(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              horizontalSpaceTiny,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  StatusUtil.getStatusDisplayText(status),
                  style: GoogleFonts.redHatDisplay(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceSmall,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date/Time:',
                style: GoogleFonts.redHatDisplay(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$date, $time',
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceTiny,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description:',
                style: GoogleFonts.redHatDisplay(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: Text(
                  description ?? address,
                  style: GoogleFonts.redHatDisplay(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          verticalSpaceMedium,

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.redHatDisplay(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? kcWhiteColor : kcBlackColor,
                      ),
                    ),
                  ),
                ),
              ),
              if (canCancel) ...[
                horizontalSpaceSmall,
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancelRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }
}