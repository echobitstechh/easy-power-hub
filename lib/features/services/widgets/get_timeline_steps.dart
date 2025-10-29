import '../../../core/utils/string_util.dart';
import '../../../core/data/models/timeline_step.dart';
import '../../../core/data/models/service_request.dart';

  List<TimelineStep> getTimelineSteps(ServiceRequest serviceRequest) {
    final status = serviceRequest.status.toLowerCase();
    final steps = <TimelineStep>[];

    steps.add(TimelineStep(
      title: 'Request Submitted',
      description: 'Your service request has been received',
      timestamp: formatDateTime(serviceRequest.createdAt),
      isCompleted: true,
    ));

    if (status == 'cancelled') {
      steps.add(TimelineStep(
        title: 'Request Cancelled',
        description: serviceRequest.reason ?? 'You cancelled this service request',
        timestamp: formatDateTime(serviceRequest.updatedAt),
        isCompleted: true,
        isError: true,
      ));
      return steps;
    } else if (status == 'declined') {
      steps.add(TimelineStep(
        title: 'Request Declined',
        description: serviceRequest.reason ?? 'Your service request was declined',
        timestamp: formatDateTime(serviceRequest.updatedAt),
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
        timestamp: formatDateTime(serviceRequest.updatedAt),
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
        timestamp: formatDateTime(serviceRequest.updatedAt),
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
