import 'package:flutter/material.dart';

/// Where a disciplinary incident sits in its lifecycle.
enum IncidentStatus {
  open,
  underInvestigation,
  awaitingResponse,
  underReview,
  confirmed,
  rejected,
  closed,
}

class DisciplineEnums {
  /// The API sends human-readable statuses ("Under Investigation"), so match
  /// on a normalised form rather than exact strings.
  static IncidentStatus statusFrom(String? raw) {
    final key = (raw ?? '').toLowerCase().replaceAll(RegExp(r'[\s_]'), '');
    return switch (key) {
      'underinvestigation' => IncidentStatus.underInvestigation,
      'awaitingemployeeresponse' ||
      'awaitingresponse' => IncidentStatus.awaitingResponse,
      'underreview' => IncidentStatus.underReview,
      'confirmed' => IncidentStatus.confirmed,
      'rejected' => IncidentStatus.rejected,
      'closed' => IncidentStatus.closed,
      _ => IncidentStatus.open,
    };
  }

  /// Exact value the API expects back.
  static String statusValue(IncidentStatus s) => switch (s) {
    IncidentStatus.open => 'Open',
    IncidentStatus.underInvestigation => 'Under Investigation',
    IncidentStatus.awaitingResponse => 'Awaiting Employee Response',
    IncidentStatus.underReview => 'Under Review',
    IncidentStatus.confirmed => 'Confirmed',
    IncidentStatus.rejected => 'Rejected',
    IncidentStatus.closed => 'Closed',
  };

  static Color statusColor(IncidentStatus s) => switch (s) {
    IncidentStatus.open => const Color(0xff64748B),
    IncidentStatus.underInvestigation => const Color(0xffF59E0B),
    IncidentStatus.awaitingResponse => const Color(0xffEA7A1E),
    IncidentStatus.underReview => const Color(0xffD9A400),
    IncidentStatus.confirmed => const Color(0xff10B981),
    IncidentStatus.rejected => const Color(0xffEF4444),
    IncidentStatus.closed => const Color(0xff64748B),
  };

  static IconData statusIcon(IncidentStatus s) => switch (s) {
    IncidentStatus.open => Icons.folder_open_rounded,
    IncidentStatus.underInvestigation => Icons.search_rounded,
    IncidentStatus.awaitingResponse => Icons.record_voice_over_outlined,
    IncidentStatus.underReview => Icons.gavel_rounded,
    IncidentStatus.confirmed => Icons.check_circle_rounded,
    IncidentStatus.rejected => Icons.cancel_rounded,
    IncidentStatus.closed => Icons.inventory_2_outlined,
  };

  /// Statuses an admin may move an incident to directly.
  static const List<IncidentStatus> adminStatusTargets = [
    IncidentStatus.underInvestigation,
    IncidentStatus.awaitingResponse,
    IncidentStatus.closed,
  ];

  static const List<String> warningTypes = [
    'Verbal Warning',
    'First Written Warning',
    'Second Written Warning',
    'Final Written Warning',
    'Suspension Notice',
  ];
}

class DisciplineIncident {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime? incidentDate;
  final String description;
  final IncidentStatus status;
  final String category;
  final String justification;
  final DateTime? justificationSubmittedAt;
  final String reviewerComments;
  final String disposition;
  final bool countsTowardWarning;
  final DateTime? createdAt;

  const DisciplineIncident({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.description,
    required this.status,
    required this.category,
    required this.justification,
    required this.reviewerComments,
    required this.disposition,
    required this.countsTowardWarning,
    this.incidentDate,
    this.justificationSubmittedAt,
    this.createdAt,
  });

  /// Employees may write or change their explanation until HR finalises it.
  bool get canSubmitJustification =>
      status != IncidentStatus.confirmed &&
      status != IncidentStatus.rejected &&
      status != IncidentStatus.closed;

  /// HR may still edit the record before a final determination.
  bool get isEditableByAdmin => canSubmitJustification;

  bool get needsEmployeeAction =>
      status == IncidentStatus.awaitingResponse && justification.isEmpty;

  factory DisciplineIncident.fromJson(Map<String, dynamic> json) {
    String str(String key) =>
        '${json[key] ?? ''}'.trim() == 'null' ? '' : '${json[key] ?? ''}';

    return DisciplineIncident(
      id: '${json['incident_id'] ?? json['id'] ?? ''}',
      employeeId: str('employee_id'),
      employeeName: str('employee_name'),
      incidentDate: DateTime.tryParse('${json['incident_date']}')?.toLocal(),
      description: str('description'),
      status: DisciplineEnums.statusFrom('${json['status']}'),
      category: str('category'),
      justification: str('employee_justification'),
      justificationSubmittedAt:
          DateTime.tryParse('${json['justification_submitted_at']}')?.toLocal(),
      reviewerComments: str('reviewer_comments'),
      disposition: str('disposition'),
      countsTowardWarning: json['counts_toward_warning'] == true,
      createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
    );
  }
}

class DisciplineWarning {
  final String id;
  final String incidentId;
  final String employeeId;
  final String employeeName;
  final DateTime? letterDate;
  final String warningType;
  final String content;
  final String issuedByName;
  final DateTime? createdAt;

  const DisciplineWarning({
    required this.id,
    required this.incidentId,
    required this.employeeId,
    required this.employeeName,
    required this.warningType,
    required this.content,
    required this.issuedByName,
    this.letterDate,
    this.createdAt,
  });

  /// Severity rises through the warning ladder; used to tint the letter.
  Color get accent {
    final key = warningType.toLowerCase();
    if (key.contains('final') || key.contains('suspension')) {
      return const Color(0xffEF4444);
    }
    if (key.contains('second')) return const Color(0xffEA7A1E);
    if (key.contains('first')) return const Color(0xffF59E0B);
    return const Color(0xff64748B);
  }

  factory DisciplineWarning.fromJson(Map<String, dynamic> json) =>
      DisciplineWarning(
        id: '${json['warning_id'] ?? json['id'] ?? ''}',
        incidentId: '${json['incident_id'] ?? ''}',
        employeeId: '${json['employee_id'] ?? ''}',
        employeeName: '${json['employee_name'] ?? ''}',
        letterDate: DateTime.tryParse('${json['letter_date']}')?.toLocal(),
        warningType: '${json['warning_type'] ?? ''}',
        content: '${json['content'] ?? ''}',
        issuedByName: '${json['issued_by_name'] ?? ''}',
        createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
      );
}

class WarningEligibility {
  final int confirmedCount;
  final bool eligible;
  final int threshold;

  const WarningEligibility({
    required this.confirmedCount,
    required this.eligible,
    required this.threshold,
  });

  factory WarningEligibility.fromJson(Map<String, dynamic> json) =>
      WarningEligibility(
        confirmedCount:
            int.tryParse('${json['confirmed_incident_count'] ?? 0}') ?? 0,
        eligible: json['warning_eligible'] == true,
        threshold: int.tryParse('${json['threshold'] ?? 0}') ?? 0,
      );
}
