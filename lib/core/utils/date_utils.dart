import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    }
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  static DateTime? parseDateFromString(String dateString) {
    try {
      // Try common formats
      final formats = [
        'yyyy-MM-dd',
        'MM/dd/yyyy',
        'dd/MM/yyyy',
        'MMM dd, yyyy',
      ];
      
      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (_) {
          // Try next format
        }
      }
      
      // Try to extract date from natural language
      final now = DateTime.now();
      
      if (dateString.toLowerCase().contains('today')) {
        return DateTime(now.year, now.month, now.day);
      }
      
      if (dateString.toLowerCase().contains('tomorrow')) {
        return DateTime(now.year, now.month, now.day + 1);
      }
      
      if (dateString.toLowerCase().contains('next week')) {
        return DateTime(now.year, now.month, now.day + 7);
      }
      
      // Could not parse date
      return null;
    } catch (e) {
      return null;
    }
  }
}