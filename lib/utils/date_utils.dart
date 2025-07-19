import 'package:intl/intl.dart';

class DateUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static bool isBeforeYesterday(DateTime date) {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return date.isBefore(DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day));
  }

  static int getDaysInMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    if (month == DateTime.february) {
      final isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    final daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month];
  }

  static int getWeekday(DateTime date) {
    return date.weekday; // Monday = 1, Sunday = 7
  }

  static String formatDate(DateTime date, String format) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  static DateTime parseDate(String dateString, String format) {
    final formatter = DateFormat(format);
    return formatter.parse(dateString);
  }

  static int calculateCurrentStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return 0;
    }

    final sortedCompletedDates = completedDates.toList()..sort();
    int currentStreak = 0;
    final now = DateTime.now();

    if (DateUtils.isSameDay(sortedCompletedDates.last, now)) {
      currentStreak = 1;
      DateTime lastDate = sortedCompletedDates.last;
      for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
        if (DateUtils.isYesterday(sortedCompletedDates[i])) {
          currentStreak++;
          lastDate = sortedCompletedDates[i];
        } else if (!DateUtils.isSameDay(sortedCompletedDates[i], lastDate)) {
          break;
        }
      }
    } else {
      final yesterday = now.subtract(const Duration(days: 1));
      if (DateUtils.isSameDay(sortedCompletedDates.last, yesterday)) {
        currentStreak = 1;
        DateTime lastDate = sortedCompletedDates.last;
        for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
          if (DateUtils.isYesterday(sortedCompletedDates[i])) {
            currentStreak++;
            lastDate = sortedCompletedDates[i];
          } else if (!DateUtils.isSameDay(sortedCompletedDates[i], lastDate)) {
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
      if (lastDate == null || DateUtils.isYesterday(sortedCompletedDates[i])) {
        tempStreak++;
      } else if (!DateUtils.isSameDay(sortedCompletedDates[i], lastDate!)){
        tempStreak = 1;
      }

      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
      lastDate = sortedCompletedDates[i];
    }

    return longestStreak;
  }

  static double calculateCompletionRate(List<DateTime> completedDates, DateTime startDate, DateTime endDate) {
    if (completedDates.isEmpty) {
      return 0.0;
    }

    final filteredDates = completedDates.where((date) =>
        !date.isBefore(DateTime(startDate.year, startDate.month, startDate.day)) &&
        !date.isAfter(DateTime(endDate.year, endDate.month, endDate.day)))
        .toList();

    if (filteredDates.isEmpty) {
      return 0.0;
    }

    final uniqueDates = filteredDates.map((date) => DateTime(date.year, date.month, date.day)).toSet();
    final numberOfDays = endDate.difference(startDate).inDays + 1;

    return (uniqueDates.length / numberOfDays) * 100;
  }

  static double calculateOverallCompletionRate(List<DateTime> completedDates, DateTime habitCreationDate) {
     if (completedDates.isEmpty) {
      return 0.0;
    }

    final uniqueDates = completedDates.map((date) => DateTime(date.year, date.month, date.day)).toSet();
    final today = DateTime.now();
    final numberOfDays = today.difference(habitCreationDate).inDays + 1;

    return (uniqueDates.length / numberOfDays) * 100;
  }



}
