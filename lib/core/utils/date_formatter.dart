import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat.yMMMMd('ar_DZ').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat.Hm('ar_DZ').format(date);
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatFull(date);
    } else if (difference.inDays > 1) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inHours > 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
