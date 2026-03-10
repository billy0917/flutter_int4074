import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime dt, {String locale = 'zh'}) {
    if (locale == 'zh') {
      return '${dt.year}年${dt.month}月${dt.day}日';
    } else {
      return DateFormat('MMM d, yyyy').format(dt);
    }
  }

  static String formatTime(DateTime dt, {String locale = 'zh'}) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    if (locale == 'zh') {
      final period = h < 12 ? '上午' : (h < 18 ? '下午' : '晚上');
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      return '$period $hour12:$m';
    } else {
      return DateFormat('h:mm a').format(dt);
    }
  }

  static String groupKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
