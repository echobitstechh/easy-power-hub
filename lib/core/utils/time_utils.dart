

String formatRemainingTime(DateTime drawDate) {
  final now = DateTime.now();
  final difference = drawDate.difference(now);
  final hours = difference.inHours;
  final minutes = difference.inMinutes.remainder(60);
  final seconds = difference.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}