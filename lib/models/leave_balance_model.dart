class LeaveBalance {
  final String? leaveTypeId;
  final String? leaveTypeName;
  final int? year;
  final num entitled;
  final num taken;
  final num balance;

  LeaveBalance({
    this.leaveTypeId,
    this.leaveTypeName,
    this.year,
    this.entitled = 0,
    this.taken = 0,
    this.balance = 0,
  });

  static num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? "") ?? 0;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory LeaveBalance.fromMap(Map<String, dynamic> map) {
    return LeaveBalance(
      leaveTypeId: map['leave_type_id']?.toString(),
      leaveTypeName: map['leave_type_name']?.toString(),
      year: _toInt(map['year']),
      entitled: _toNum(map['entitled']),
      taken: _toNum(map['taken']),
      balance: _toNum(map['balance']),
    );
  }

  /// Fraction of the entitlement already used (0.0–1.0).
  double get usedFraction {
    if (entitled <= 0) return 0;
    final f = taken / entitled;
    if (f.isNaN || f.isInfinite) return 0;
    return f.clamp(0.0, 1.0).toDouble();
  }
}
