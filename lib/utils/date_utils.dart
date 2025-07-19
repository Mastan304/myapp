class DateUtils {
  static bool isSameDay(int? timestamp1, int? timestamp2) {
    if (timestamp1 == null || timestamp2 == null) {
      return false;
    }
    final date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
    final date2 = DateTime.fromMillisecondsSinceEpoch(timestamp2);
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isYesterday(int? timestamp) {
    if (timestamp == null) {
      return false;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isBeforeYesterday(int? timestamp) {
    if (timestamp == null) {
      return false;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    // Check if the date is before two days ago, ignoring time
    return date.isBefore(DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day));
  }

  static int calculateCurrentStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return 0;
    }

    final sortedCompletedDates = completedDates.toList()..sort();
    int currentStreak = 0;
    final now = DateTime.now();

    if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, now.millisecondsSinceEpoch)) {
      currentStreak = 1;
      DateTime lastDate = sortedCompletedDates.last;
      for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
        if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
          currentStreak++;
          lastDate = sortedCompletedDates[i];
        } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
          break;
        }
      }
    } else {
      final yesterday = now.subtract(const Duration(days: 1));
      if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, yesterday.millisecondsSinceEpoch)) {
        currentStreak = 1;
        DateTime lastDate = sortedCompletedDates.last;
        for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
          if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
            currentStreak++;
            lastDate = sortedCompletedDates[i];
          } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
            break;
          }
        }
      } else {
        currentStreak = 0;
      }
    }

    return currentStreak;
  }

  static int calculateLongestStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return 0;
    }

    final sortedCompletedDates = completedDates.toList()..sort();
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate = null;

    for (int i = 0; i < sortedCompletedDates.length; i++) {
      if (lastDate == null || DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
        tempStreak++;
      } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)){
        tempStreak = 1;
      }

      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
      lastDate = sortedCompletedDates[i];
    }

    return longestStreak;
  }
}
