import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper._(); // Prevent instantiation

  /// -------------------------------------------------------
  /// Convert raw string date into a formatted date like:
  /// "2025-01-12" → "Jan 12, 2025"
  /// -------------------------------------------------------
  static String formatDate(String? rawDate, {String format = "MMM dd, yyyy"}) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      final date = DateTime.parse(rawDate);
      return DateFormat(format).format(date);
    } catch (_) {
      return rawDate;
    }
  }

  /// -------------------------------------------------------
  /// Convert raw time string + handle AM / PM:
  /// "18:25:00" → "06:25 PM"
  /// -------------------------------------------------------
  static String formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "-";

    try {
      final time = DateFormat("HH:mm:ss").parse(rawTime);
      return DateFormat("hh:mm a").format(time); // 12hr format with AM/PM
    } catch (_) {
      return rawTime;
    }
  }

  /// -------------------------------------------------------
  /// Convert UTC/GMT timestamp to LOCAL time:
  /// "2025-01-12T14:45:00Z" → "07:45 PM" (local based)
  /// -------------------------------------------------------
  static String utcToLocalTime(String? utcDateTime) {
    if (utcDateTime == null || utcDateTime.isEmpty) return "-";

    try {
      final date = DateTime.parse(utcDateTime).toLocal();
      return DateFormat("hh:mm a").format(date);
    } catch (_) {
      return utcDateTime;
    }
  }

  /// -------------------------------------------------------
  /// Convert UTC/GMT timestamp to LOCAL date:
  /// "2025-01-12T14:45:00Z" → "Jan 12, 2025"
  /// -------------------------------------------------------
  static String utcToLocalDate(
    String? utcDateTime, {
    String format = "MMM dd, yyyy",
  }) {
    if (utcDateTime == null || utcDateTime.isEmpty) return "-";

    try {
      final date = DateTime.parse(utcDateTime).toLocal();
      return DateFormat(format).format(date);
    } catch (_) {
      return utcDateTime;
    }
  }

  /// -------------------------------------------------------
  /// Combine Date + Time:
  /// "2025-01-12T14:45:00Z" → "Jan 12, 2025 • 07:45 PM"
  /// -------------------------------------------------------
  static String formatDateTimeLocal(String? utcDateTime) {
    if (utcDateTime == null || utcDateTime.isEmpty) return "-";

    try {
      final date = DateTime.parse(utcDateTime).toLocal();
      final formattedDate = DateFormat("MMM dd, yyyy").format(date);
      final formattedTime = DateFormat("hh:mm a").format(date);
      return "$formattedDate • $formattedTime";
    } catch (_) {
      return utcDateTime;
    }
  }

  /// -------------------------------------------------------
  /// Convert DateTime → API (UTC ISO Format)
  /// -------------------------------------------------------
  static String toUtcString(DateTime date) {
    return date.toUtc().toIso8601String();
  }
}
