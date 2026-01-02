import 'dart:convert';
import 'package:supergithr/models/attendance_logs.dart';

class TodayLogsModel {
  final bool currentlyClockedIn;
  final List<AttendanceLog> logs;
  final String totalWorkTime;

  TodayLogsModel({
    required this.currentlyClockedIn,
    required this.logs,
    required this.totalWorkTime,
  });

  factory TodayLogsModel.fromMap(Map<String, dynamic> map) {
    return TodayLogsModel(
      currentlyClockedIn: map['currently_clocked_in'] ?? false,
      logs: AttendanceLog.listFromJson(map['logs'] ?? []),
      totalWorkTime: map['total_work_time'] ?? "00h:00m:00s",
    );
  }

  Map<String, dynamic> toMap() => {
    'currently_clocked_in': currentlyClockedIn,
    'logs': logs.map((e) => e.toMap()).toList(),
    'total_work_time': totalWorkTime,
  };

  factory TodayLogsModel.fromJson(String source) =>
      TodayLogsModel.fromMap(json.decode(source));
}
