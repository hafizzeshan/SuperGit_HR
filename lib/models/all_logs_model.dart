import 'dart:convert';
import 'package:supergithr/models/attendance_logs.dart';

class AllLogsModel {
  final List<AttendanceLog> logs;
  final int monthlySeconds;
  final String monthlyTime;
  final int todaySeconds;
  final String todayTime;
  final int totalSeconds;
  final String totalWorkTime;
  final int weeklySeconds;
  final String weeklyTime;

  AllLogsModel({
    required this.logs,
    required this.monthlySeconds,
    required this.monthlyTime,
    required this.todaySeconds,
    required this.todayTime,
    required this.totalSeconds,
    required this.totalWorkTime,
    required this.weeklySeconds,
    required this.weeklyTime,
  });

  factory AllLogsModel.fromMap(Map<String, dynamic> map) {
    return AllLogsModel(
      logs: AttendanceLog.listFromJson(map['logs'] ?? []),
      monthlySeconds: map['monthly_seconds'] ?? 0,
      monthlyTime: map['monthly_time'] ?? '',
      todaySeconds: map['today_seconds'] ?? 0,
      todayTime: map['today_time'] ?? '',
      totalSeconds: map['total_seconds'] ?? 0,
      totalWorkTime: map['total_work_time'] ?? '',
      weeklySeconds: map['weekly_seconds'] ?? 0,
      weeklyTime: map['weekly_time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'logs': logs.map((e) => e.toMap()).toList(),
    'monthly_seconds': monthlySeconds,
    'monthly_time': monthlyTime,
    'today_seconds': todaySeconds,
    'today_time': todayTime,
    'total_seconds': totalSeconds,
    'total_work_time': totalWorkTime,
    'weekly_seconds': weeklySeconds,
    'weekly_time': weeklyTime,
  };

  factory AllLogsModel.fromJson(String source) =>
      AllLogsModel.fromMap(json.decode(source));
}
