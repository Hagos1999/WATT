import 'package:intl/intl.dart';

/// Date/time formatting utilities
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('MMM dd');
  static final DateFormat _fullDateFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _chartDateFormat = DateFormat('HH:mm');
  static final DateFormat _chartDayFormat = DateFormat('MM/dd');

  /// Format as "14:30:05"
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// Format as "May 06"
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// Format as "May 06, 2026 14:30"
  static String formatFull(DateTime dt) => _fullDateFormat.format(dt);

  /// Format for chart x-axis (same day) — "14:30"
  static String formatChartTime(DateTime dt) => _chartDateFormat.format(dt);

  /// Format for chart x-axis (multi-day) — "05/06"
  static String formatChartDay(DateTime dt) => _chartDayFormat.format(dt);

  /// Human-readable "X seconds ago", "X minutes ago", etc.
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 5) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Get start of today
  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get start of N days ago
  static DateTime daysAgo(int days) {
    return startOfToday.subtract(Duration(days: days));
  }
}
