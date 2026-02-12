class AttendanceHistoryModel {
  List<Months>? months;

  AttendanceHistoryModel({this.months});

  AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['months'] != null) {
      months = <Months>[];
      json['months'].forEach((v) {
        months!.add(Months.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (months != null) {
      data['months'] = months!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Months {
  String? month;
  String? totalTime;
  List<Weeks>? weeks;

  Months({this.month, this.totalTime, this.weeks});

  Months.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    totalTime = json['total_time'];
    if (json['weeks'] != null) {
      weeks = <Weeks>[];
      json['weeks'].forEach((v) {
        weeks!.add(Weeks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month'] = month;
    data['total_time'] = totalTime;
    if (weeks != null) {
      data['weeks'] = weeks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Weeks {
  String? week;
  String? totalTime;
  List<Days>? days;

  Weeks({this.week, this.totalTime, this.days});

  Weeks.fromJson(Map<String, dynamic> json) {
    week = json['week'];
    totalTime = json['total_time'];
    if (json['days'] != null) {
      days = <Days>[];
      json['days'].forEach((v) {
        days!.add(Days.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['week'] = week;
    data['total_time'] = totalTime;
    if (days != null) {
      data['days'] = days!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Days {
  String? date;
  String? totalTime;
  List<Logs>? logs;

  Days({this.date, this.totalTime, this.logs});

  Days.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    totalTime = json['total_time'];
    if (json['logs'] != null) {
      logs = <Logs>[];
      json['logs'].forEach((v) {
        logs!.add(Logs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['total_time'] = totalTime;
    if (logs != null) {
      data['logs'] = logs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Logs {
  String? id;
  String? employeeId;
  String? clockType;
  String? clockTime;
  String? method;
  String? sourceDevice;
  Location? location;
  String? remarks;
  String? createdAt;
  String? updatedAt;

  Logs({
    this.id,
    this.employeeId,
    this.clockType,
    this.clockTime,
    this.method,
    this.sourceDevice,
    this.location,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  Logs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    clockType = json['clock_type'];
    clockTime = json['clock_time'];
    method = json['method'];
    sourceDevice = json['source_device'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    remarks = json['remarks'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['clock_type'] = clockType;
    data['clock_time'] = clockTime;
    data['method'] = method;
    data['source_device'] = sourceDevice;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
