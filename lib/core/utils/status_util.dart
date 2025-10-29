import 'package:flutter/material.dart';

class StatusUtil {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'declined':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'declined':
        return 'Declined';
      default:
        return status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).toLowerCase()
            : status;
    }
  }

  static bool canCancel(String status) {
    final statusLower = status.toLowerCase();
    return statusLower == 'pending' || statusLower == 'accepted';
  }
}