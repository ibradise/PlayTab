String formatBirr(int amount) => '$amount birr';

String formatDateTime(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '${months[dt.month - 1]} ${dt.day}, $hh:$mm';
}
