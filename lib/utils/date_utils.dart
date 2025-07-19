class DateUtils {
  static bool isSameDay(int? timestamp1, int? timestamp2) {
    if (timestamp1 == null || timestamp2 == null) {
      return false;
    }
    final date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1 * 1000);
    final date2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isYesterday(int? timestamp) {
    if (timestamp == null) {
      return false;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isBeforeYesterday(int? timestamp) {
    if (timestamp == null) {
      return false;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    // Check if the date is before two days ago, ignoring time
    return date.isBefore(DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day));
  }
}