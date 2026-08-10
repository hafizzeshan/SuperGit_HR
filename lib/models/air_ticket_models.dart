import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// Entitlement
// ─────────────────────────────────────────────────────────────
class AirTicketEntitlement {
  final String id;
  final String employeeId;
  final int year;
  final String? policyId;
  final int eligibleTickets;
  final int usedTickets;
  final int remainingTickets;
  final DateTime? lastIssuedAt;
  final String status;
  final bool isEligible;
  final String eligibilityReason;
  final String ticketFrequency; // none | annual | biennial

  AirTicketEntitlement({
    required this.id,
    required this.employeeId,
    required this.year,
    this.policyId,
    required this.eligibleTickets,
    required this.usedTickets,
    required this.remainingTickets,
    this.lastIssuedAt,
    required this.status,
    required this.isEligible,
    this.eligibilityReason = '',
    this.ticketFrequency = '',
  });

  /// Apply button should only be enabled when this is true.
  bool get canApply => isEligible && remainingTickets > 0;

  factory AirTicketEntitlement.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return AirTicketEntitlement(
      id: map['id'] ?? '',
      employeeId: map['employee_id'] ?? '',
      year: (map['year'] ?? 0) is int
          ? map['year']
          : int.tryParse('${map['year']}') ?? 0,
      policyId: map['policy_id'],
      eligibleTickets: (map['eligible_tickets'] ?? 0) as int,
      usedTickets: (map['used_tickets'] ?? 0) as int,
      remainingTickets: (map['remaining_tickets'] ?? 0) as int,
      lastIssuedAt: parseDate(map['last_issued_at']),
      status: map['status'] ?? '',
      isEligible: map['is_eligible'] == true,
      eligibilityReason: map['eligibility_reason'] ?? '',
      ticketFrequency: map['ticket_frequency'] ?? '',
    );
  }

  factory AirTicketEntitlement.fromJson(String source) =>
      AirTicketEntitlement.fromMap(json.decode(source));
}

// ─────────────────────────────────────────────────────────────
// Passenger
// ─────────────────────────────────────────────────────────────
class AirTicketPassenger {
  final String? id;
  final String? requestId;
  final String? passengerType;
  final String name;
  final String? relationship;
  final String passportNumber;
  final String? iqamaNumber;
  final DateTime? dateOfBirth;

  AirTicketPassenger({
    this.id,
    this.requestId,
    this.passengerType,
    required this.name,
    this.relationship,
    required this.passportNumber,
    this.iqamaNumber,
    this.dateOfBirth,
  });

  factory AirTicketPassenger.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return AirTicketPassenger(
      id: map['id'],
      requestId: map['request_id'],
      passengerType: map['passenger_type'],
      name: map['name'] ?? '',
      relationship: map['relationship'],
      passportNumber: map['passport_number'] ?? '',
      iqamaNumber: map['iqama_number'],
      dateOfBirth: parseDate(map['date_of_birth']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    String? fmt(DateTime? d) =>
        d == null ? null : "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    return {
      'name': name,
      if (relationship != null) 'relationship': relationship,
      'passport_number': passportNumber,
      if (iqamaNumber != null) 'iqama_number': iqamaNumber,
      if (dateOfBirth != null) 'date_of_birth': fmt(dateOfBirth),
    };
  }
}

// ─────────────────────────────────────────────────────────────
// Approval
// ─────────────────────────────────────────────────────────────
class AirTicketApproval {
  final String id;
  final String requestId;
  final String stage;
  final String? approvedBy;
  final String action;
  final String? comments;
  final DateTime? actionAt;

  AirTicketApproval({
    required this.id,
    required this.requestId,
    required this.stage,
    this.approvedBy,
    required this.action,
    this.comments,
    this.actionAt,
  });

  factory AirTicketApproval.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return AirTicketApproval(
      id: map['id'] ?? '',
      requestId: map['request_id'] ?? '',
      stage: map['stage'] ?? '',
      approvedBy: map['approved_by'],
      action: map['action'] ?? '',
      comments: map['comments'],
      actionAt: parseDate(map['action_at']),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Booking
// ─────────────────────────────────────────────────────────────
class AirTicketBooking {
  final String id;
  final String requestId;
  final String airline;
  final String pnr;
  final String ticketNumber;
  final String? travelAgency;
  final double finalCost;
  final String? invoiceNumber;
  final String bookingStatus;
  final DateTime? issuedAt;

  AirTicketBooking({
    required this.id,
    required this.requestId,
    required this.airline,
    required this.pnr,
    required this.ticketNumber,
    this.travelAgency,
    required this.finalCost,
    this.invoiceNumber,
    required this.bookingStatus,
    this.issuedAt,
  });

  factory AirTicketBooking.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return AirTicketBooking(
      id: map['id'] ?? '',
      requestId: map['request_id'] ?? '',
      airline: map['airline'] ?? '',
      pnr: map['pnr'] ?? '',
      ticketNumber: map['ticket_number'] ?? '',
      travelAgency: map['travel_agency'],
      finalCost: (map['final_cost'] ?? 0).toDouble(),
      invoiceNumber: map['invoice_number'],
      bookingStatus: map['booking_status'] ?? '',
      issuedAt: parseDate(map['issued_at']),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Request (list item + base)
// ─────────────────────────────────────────────────────────────
class AirTicketRequest {
  final String id;
  final String requestId;
  final String employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String requestType;
  final String travelType;
  final String fromCity;
  final String toCity;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String? preferredAirline;
  final String travelClass;
  final double? estimatedCost;
  final String? currency;
  final String status;
  final String? approvalStage;
  final String? remarks;
  final DateTime? createdAt;

  AirTicketRequest({
    required this.id,
    required this.requestId,
    required this.employeeId,
    this.employeeName,
    this.employeeCode,
    required this.requestType,
    required this.travelType,
    required this.fromCity,
    required this.toCity,
    this.departureDate,
    this.returnDate,
    this.preferredAirline,
    required this.travelClass,
    this.estimatedCost,
    this.currency,
    required this.status,
    this.approvalStage,
    this.remarks,
    this.createdAt,
  });

  factory AirTicketRequest.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return AirTicketRequest(
      id: map['id'] ?? '',
      requestId: map['request_id'] ?? '',
      employeeId: map['employee_id'] ?? '',
      employeeName: map['employee_name'],
      employeeCode: map['employee_code'],
      requestType: map['request_type'] ?? '',
      travelType: map['travel_type'] ?? '',
      fromCity: map['from_city'] ?? '',
      toCity: map['to_city'] ?? '',
      departureDate: parseDate(map['departure_date']),
      returnDate: parseDate(map['return_date']),
      preferredAirline: map['preferred_airline'],
      travelClass: map['travel_class'] ?? '',
      estimatedCost: map['estimated_cost'] == null
          ? null
          : (map['estimated_cost'] as num).toDouble(),
      currency: map['currency'],
      status: map['status'] ?? '',
      approvalStage: map['approval_stage'],
      remarks: map['remarks'],
      createdAt: parseDate(map['created_at']),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Request Details (full)
// ─────────────────────────────────────────────────────────────
class AirTicketRequestDetails {
  final AirTicketRequest request;
  final List<AirTicketPassenger> passengers;
  final List<AirTicketApproval> approvals;
  final AirTicketBooking? booking;

  AirTicketRequestDetails({
    required this.request,
    required this.passengers,
    required this.approvals,
    this.booking,
  });

  factory AirTicketRequestDetails.fromMap(Map<String, dynamic> map) {
    return AirTicketRequestDetails(
      request: AirTicketRequest.fromMap(
        Map<String, dynamic>.from(map['request'] ?? {}),
      ),
      passengers: (map['passengers'] as List? ?? [])
          .map((e) => AirTicketPassenger.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      approvals: (map['approvals'] as List? ?? [])
          .map((e) => AirTicketApproval.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      booking: map['booking'] is Map
          ? AirTicketBooking.fromMap(Map<String, dynamic>.from(map['booking']))
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// List with pagination
// ─────────────────────────────────────────────────────────────
class AirTicketRequestList {
  final List<AirTicketRequest> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AirTicketRequestList({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AirTicketRequestList.fromMap(Map<String, dynamic> map) {
    final items = (map['data'] as List? ?? [])
        .map((e) => AirTicketRequest.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final pagination = Map<String, dynamic>.from(map['pagination'] ?? {});
    return AirTicketRequestList(
      items: items,
      page: (pagination['page'] ?? 1) as int,
      limit: (pagination['limit'] ?? 10) as int,
      total: (pagination['total'] ?? items.length) as int,
      totalPages: (pagination['totalPages'] ?? 1) as int,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Create DTO
// ─────────────────────────────────────────────────────────────
class CreateAirTicketRequestDTO {
  final String employeeId;
  final String? leaveRequestId;
  final String requestType; // annual_leave | emergency | personal
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String? preferredAirline;
  final String travelClass; // economy | business | first
  final String travelType; // self | self_family
  final List<AirTicketPassenger> passengers;
  final String? remarks;

  CreateAirTicketRequestDTO({
    required this.employeeId,
    this.leaveRequestId,
    required this.requestType,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    this.returnDate,
    this.preferredAirline,
    required this.travelClass,
    required this.travelType,
    this.passengers = const [],
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    String fmt(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    return {
      'employee_id': employeeId,
      if (leaveRequestId != null) 'leave_request_id': leaveRequestId,
      'request_type': requestType,
      'from_city': fromCity,
      'to_city': toCity,
      'departure_date': fmt(departureDate),
      if (returnDate != null) 'return_date': fmt(returnDate!),
      if (preferredAirline != null) 'preferred_airline': preferredAirline,
      'travel_class': travelClass,
      'travel_type': travelType,
      if (passengers.isNotEmpty)
        'passengers': passengers.map((p) => p.toCreateMap()).toList(),
      if (remarks != null) 'remarks': remarks,
    };
  }
}
