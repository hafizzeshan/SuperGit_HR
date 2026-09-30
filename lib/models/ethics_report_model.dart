import 'package:flutter/material.dart';

/// Lifecycle of an ethics report. The employee may only edit while [pending].
enum EthicsStatus { pending, underReview, investigating, resolved, closed }

enum EthicsSeverity { low, medium, high, critical }

class EthicsEnums {
  static EthicsStatus statusFrom(String? key) {
    switch (key) {
      case 'under_review':
        return EthicsStatus.underReview;
      case 'investigating':
        return EthicsStatus.investigating;
      case 'resolved':
        return EthicsStatus.resolved;
      case 'closed':
        return EthicsStatus.closed;
      default:
        return EthicsStatus.pending;
    }
  }

  static String statusKey(EthicsStatus s) => switch (s) {
    EthicsStatus.pending => 'pending',
    EthicsStatus.underReview => 'under_review',
    EthicsStatus.investigating => 'investigating',
    EthicsStatus.resolved => 'resolved',
    EthicsStatus.closed => 'closed',
  };

  static Color statusColor(EthicsStatus s) => switch (s) {
    EthicsStatus.pending => const Color(0xffE08B00),
    EthicsStatus.underReview => const Color(0xff0076CE),
    EthicsStatus.investigating => const Color(0xff7A3FD6),
    EthicsStatus.resolved => const Color(0xff2E9E5B),
    EthicsStatus.closed => const Color(0xff5B6B7B),
  };

  static EthicsSeverity severityFrom(String? key) {
    switch (key) {
      case 'low':
        return EthicsSeverity.low;
      case 'high':
        return EthicsSeverity.high;
      case 'critical':
        return EthicsSeverity.critical;
      default:
        return EthicsSeverity.medium;
    }
  }

  static String severityKey(EthicsSeverity s) => s.name;

  static Color severityColor(EthicsSeverity s) => switch (s) {
    EthicsSeverity.low => const Color(0xff2E9E5B),
    EthicsSeverity.medium => const Color(0xffE08B00),
    EthicsSeverity.high => const Color(0xffE2652A),
    EthicsSeverity.critical => const Color(0xffE05260),
  };

  /// Category keys exactly as the API expects them.
  static const List<String> categories = [
    'harassment',
    'discrimination',
    'fraud',
    'safety_violation',
    'conflict_of_interest',
    'retaliation',
    'other',
  ];

  static IconData categoryIcon(String key) => switch (key) {
    'harassment' => Icons.report_gmailerrorred_rounded,
    'discrimination' => Icons.groups_rounded,
    'fraud' => Icons.account_balance_wallet_outlined,
    'safety_violation' => Icons.health_and_safety_outlined,
    'conflict_of_interest' => Icons.swap_horiz_rounded,
    'retaliation' => Icons.gavel_rounded,
    _ => Icons.help_outline_rounded,
  };
}

class EthicsNote {
  final String id;
  final String authorName;
  final String message;
  final bool isInternal;
  final DateTime? createdAt;

  const EthicsNote({
    required this.id,
    required this.authorName,
    required this.message,
    required this.isInternal,
    this.createdAt,
  });

  factory EthicsNote.fromJson(Map<String, dynamic> json) => EthicsNote(
    id: '${json['id'] ?? ''}',
    authorName: '${json['author_name'] ?? ''}',
    message: '${json['message'] ?? ''}',
    isInternal: json['is_internal'] == true,
    createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
  );
}

class EthicsAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  const EthicsAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
  });

  factory EthicsAttachment.fromJson(Map<String, dynamic> json) =>
      EthicsAttachment(
        id: '${json['id'] ?? ''}',
        fileName: '${json['file_name'] ?? ''}',
        fileUrl: '${json['file_url'] ?? ''}',
        fileType: '${json['file_type'] ?? ''}',
        fileSize: int.tryParse('${json['file_size'] ?? 0}') ?? 0,
      );

  bool get isImage => fileType.startsWith('image/');

  String get readableSize {
    if (fileSize >= 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (fileSize >= 1024) return '${(fileSize / 1024).round()} KB';
    return '$fileSize B';
  }
}

class EthicsReport {
  final String id;
  final String referenceNumber;
  final String reporterName;
  final String category;
  final EthicsSeverity severity;
  final EthicsStatus status;
  final DateTime? incidentDate;
  final String incidentLocation;
  final String peopleInvolved;
  final String description;
  final bool immediateDanger;
  final List<EthicsNote> notes;
  final List<EthicsAttachment> attachments;
  final String resolutionSummary;
  final DateTime? createdAt;

  const EthicsReport({
    required this.id,
    required this.referenceNumber,
    required this.reporterName,
    required this.category,
    required this.severity,
    required this.status,
    required this.incidentLocation,
    required this.peopleInvolved,
    required this.description,
    required this.immediateDanger,
    required this.notes,
    required this.attachments,
    required this.resolutionSummary,
    this.incidentDate,
    this.createdAt,
  });

  /// Employees may only change a report while HR has not picked it up.
  bool get isEditable => status == EthicsStatus.pending;

  /// Internal HR notes must never reach the reporter.
  List<EthicsNote> get visibleNotes =>
      notes.where((n) => !n.isInternal).toList();

  factory EthicsReport.fromJson(Map<String, dynamic> json) {
    List<T> listOf<T>(dynamic raw, T Function(Map<String, dynamic>) build) {
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map>()
          .map((e) => build(Map<String, dynamic>.from(e)))
          .toList();
    }

    return EthicsReport(
      id: '${json['id'] ?? ''}',
      referenceNumber: '${json['reference_number'] ?? ''}',
      reporterName: '${json['reporter_employee_name'] ?? ''}',
      category: '${json['category'] ?? 'other'}',
      severity: EthicsEnums.severityFrom('${json['severity']}'),
      status: EthicsEnums.statusFrom('${json['status']}'),
      incidentDate: DateTime.tryParse('${json['incident_date']}')?.toLocal(),
      incidentLocation: '${json['incident_location'] ?? ''}',
      peopleInvolved: '${json['people_involved'] ?? ''}',
      description: '${json['description'] ?? ''}',
      immediateDanger: json['immediate_danger'] == true,
      notes: listOf(json['notes'], EthicsNote.fromJson),
      attachments: listOf(json['attachments'], EthicsAttachment.fromJson),
      resolutionSummary: '${json['resolution_summary'] ?? ''}',
      createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
    );
  }
}
