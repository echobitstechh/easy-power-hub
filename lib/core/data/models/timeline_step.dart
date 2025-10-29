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