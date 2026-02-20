class CreateEditRequestDTO {
  final String date;
  final String? requestedClockInTime;
  final String? requestedClockOutTime;
  final String reason;

  CreateEditRequestDTO({
    required this.date,
    this.requestedClockInTime,
    this.requestedClockOutTime,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      if (requestedClockInTime != null)
        "requested_clock_in_time": requestedClockInTime,
      if (requestedClockOutTime != null)
        "requested_clock_out_time": requestedClockOutTime,
      "reason": reason,
    };
  }
}
