class AvailableSlot {
  final String date;
  final String day;
  final String startTime;
  final String endTime;

  AvailableSlot({
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}
