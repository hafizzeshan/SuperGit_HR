class AppURL {
  // shamas
  // static const String baseUrl = 'https://jzq6qslp-8080.asse.devtunnels.ms/api/';
  // live (default — can be overridden by Firebase Remote Config)
  // The compile-time default. Used to restore the URL when the Remote Config
  // override is turned off from the app.
  static const String defaultBaseUrl = 'https://hr2.api.supergitsa.com/api/';
  static String baseUrl = defaultBaseUrl;

  static String attendanceHistory(
    String employeeId,
    String startDate,
    String endDate,
  ) =>
      "${baseUrl}attendance/history?employee_id=$employeeId&start_date=$startDate&end_date=$endDate";

  static const String loginApi = 'auth/login';
  static const String updateProfile = 'update-profile';

  static String employeeProfile(String employeeId) => 'employees/$employeeId';
  static String employeeAvatar(String employeeId) =>
      'employees/$employeeId/avatar';

  static const String registerApi = 'register';
  static const String otpVerificationApi = 'verify_otp';
  static const String forgotPasswordApi = 'recover-password';
  static const String veriftyOTP = 'verifyPass-otp';

  static const String confirmForgotPasswordApi = 'recover-password-confirm';
  static const String logOutApi = '/logout';

  // 🕒 Attendance APIs
  static const String clockInApi = "attendance/clock-in";
  static const String clockOutApi = "attendance/clock-out";
  static const String leaveTypesApi = "leave-types";
  static const String leaveRequestsApi = "leave-requests";
  static const String announcementApi = 'employees/announcement';

  static const todayLogsApi = "attendance/logs/today";
  static const allLogsApi = "attendance/logs/all";
  static const String salaryStructureApi = "payroll/structures/employee";
  static const String holidayApi = "public-holidays";

  static String editAttendanceRequest(String id) {
    return "attendance/edit-requests/$id";
  }

  // loan APIs
  static String loanApi(v) {
    return 'payroll/loans/employee/$v';
  }

  static const String loanApplyApi = 'payroll/loans';

  // ⏱️ Overtime APIs
  static const String overtimeApi = 'attendance/overtime';

  static String overtimeList({
    required String employeeId,
    int page = 1,
    int limit = 20,
  }) => '$overtimeApi?employee_id=$employeeId&page=$page&limit=$limit';

  static String leaveHistory(v) {
    return 'employees/$v/leaves';
  }

  static String leaveBalances(String employeeId, {int? year}) {
    final base = 'ess/leave-balances/$employeeId';
    return year != null ? '$base?year=$year' : base;
  }

  static String employeeDocuments(String id) {
    return 'employees/$id/documents';
  }

  static String getProfile(v) {
    return 'employees/$v';
  }

  // ✈️ Air Ticket APIs (base url already ends in /api/)
  static const String airTicketsBase = 'air-tickets';

  static String airTicketEntitlement(String employeeId, {int? year}) {
    final base = '$airTicketsBase/entitlements/$employeeId';
    return year != null ? '$base?year=$year' : base;
  }

  static String airTicketAllEntitlements(String employeeId) =>
      '$airTicketsBase/entitlements/$employeeId/all';

  static String airTicketRequests({
    String? employeeId,
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (employeeId != null && employeeId.isNotEmpty) {
      params['employee_id'] = employeeId;
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$airTicketsBase/requests?$query';
  }

  static String airTicketCreateRequest() => '$airTicketsBase/requests';

  static String airTicketRequestDetails(String requestId) =>
      '$airTicketsBase/requests/$requestId';

  static String airTicketCancelRequest(String requestId) =>
      '$airTicketsBase/requests/$requestId';

  static String airTicketBooking(String requestId) =>
      '$airTicketsBase/requests/$requestId/booking';

  // 👔 Team Leave Requests (manager / department head)
  static String teamLeaveRequests({
    required String currentApproverId,
    String status = 'PendingManager',
    int page = 1,
    int limit = 10,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'status': status,
      'current_approver_id': currentApproverId,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$leaveRequestsApi?$query';
  }

  static String teamLeaveApprove(String id) =>
      '$leaveRequestsApi/$id/manager-approve';

  static String teamLeaveReject(String id) => '$leaveRequestsApi/$id/reject';

  // 📣 Social Posts APIs
  static const String socialPostsBase = 'social-posts';

  static String socialPostsList({int page = 1, int limit = 10}) =>
      '$socialPostsBase?page=$page&limit=$limit';

  static String socialPostDetails(String postId) => '$socialPostsBase/$postId';

  static String socialPostLike(String postId) =>
      '$socialPostsBase/$postId/like';

  static String socialPostComments(String postId) =>
      '$socialPostsBase/$postId/comments';

  static String socialPostComment(String postId, String commentId) =>
      '$socialPostsBase/$postId/comments/$commentId';

  // ⚖️ Ethics Reports live on a separate service (hr2), so these are absolute
  // URLs rather than paths appended to [baseUrl].
  static const String ethicsBaseUrl = 'https://hr2.api.supergitsa.com/api';

  static String ethicsMyReports({int page = 1, int pageSize = 10}) =>
      '$ethicsBaseUrl/ethics-reports/my?page=$page&page_size=$pageSize';

  static const String ethicsReports = '$ethicsBaseUrl/ethics-reports';

  static String ethicsReport(String id) => '$ethicsBaseUrl/ethics-reports/$id';

  static String ethicsAttachments(String id) =>
      '$ethicsBaseUrl/ethics-reports/$id/attachments';

  static String ethicsAttachment(String reportId, String attachmentId) =>
      '$ethicsBaseUrl/ethics-reports/$reportId/attachments/$attachmentId';

  // ⚖️ Discipline: incidents and warning letters (hr2 service).
  static const String disciplineBase = '$ethicsBaseUrl/discipline';

  static String disciplineMyIncidents({int page = 1, int pageSize = 20}) =>
      '$disciplineBase/my-incidents?page=$page&page_size=$pageSize';

  static const String disciplineMyWarnings = '$disciplineBase/my-warnings';

  static String disciplineJustification(String incidentId) =>
      '$disciplineBase/incidents/$incidentId/justification';

  static const String disciplineIncidents = '$disciplineBase/incidents';

  static String disciplineIncidentsList({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? employeeId,
  }) {
    final params = <String>[
      'page=$page',
      'page_size=$pageSize',
      if (status != null && status.isNotEmpty)
        'status=${Uri.encodeQueryComponent(status)}',
      if (employeeId != null && employeeId.isNotEmpty)
        'employee_id=$employeeId',
    ];
    return '$disciplineIncidents?${params.join('&')}';
  }

  static String disciplineIncident(String id) => '$disciplineIncidents/$id';

  static String disciplineIncidentStatus(String id) =>
      '$disciplineIncidents/$id/status';

  static String disciplineIncidentReview(String id) =>
      '$disciplineIncidents/$id/review';

  static String disciplineEligibility(String employeeId) =>
      '$disciplineBase/employees/$employeeId/warning-eligibility';

  static const String disciplineWarnings = '$disciplineBase/warnings';

  static String disciplineWarningsList({int page = 1, int pageSize = 20}) =>
      '$disciplineWarnings?page=$page&page_size=$pageSize';

  static String disciplineWarning(String id) => '$disciplineWarnings/$id';

  // ⏱️ Overtime moved to the hr2 service along with its two-tier approvals.
  static const String overtimeBase = '$ethicsBaseUrl/attendance/overtime';

  static String overtimeListV2({
    String? employeeId,
    String? currentApproverId,
    int page = 1,
    int limit = 10,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (employeeId != null && employeeId.isNotEmpty)
        'employee_id=$employeeId',
      if (currentApproverId != null && currentApproverId.isNotEmpty)
        'current_approver_id=$currentApproverId',
      if (status != null && status.isNotEmpty) 'status=$status',
      if (month != null && month.isNotEmpty) 'month=$month',
      if (startDate != null && startDate.isNotEmpty) 'start_date=$startDate',
      if (endDate != null && endDate.isNotEmpty) 'end_date=$endDate',
    ];
    return '$overtimeBase?${params.join('&')}';
  }

  static String overtimeRecord(String id) => '$overtimeBase/$id';

  static String overtimeManagerApprove(String id) =>
      '$overtimeBase/$id/manager-approve';

  static String overtimeAdminApprove(String id) => '$overtimeBase/$id/approve';

  static String overtimeReject(String id) => '$overtimeBase/$id/reject';

  static String overtimeReportPdf({
    required String employeeId,
    required String month,
  }) => '$overtimeBase/report/pdf?employee_id=$employeeId&month=$month';

  // 🏠 Remote work lives on the same hr2 service as ethics reports.
  static const String remoteWorkBase = '$ethicsBaseUrl/attendance/remote';

  static const String remoteClockIn = '$remoteWorkBase/clock-in';
  static const String remoteClockOut = '$remoteWorkBase/clock-out';

  static String remoteMySessions({String? fromDate, String? toDate}) {
    final params = <String>[
      if (fromDate != null && fromDate.isNotEmpty) 'from_date=$fromDate',
      if (toDate != null && toDate.isNotEmpty) 'to_date=$toDate',
    ];
    return '$remoteWorkBase/my${params.isEmpty ? '' : '?${params.join('&')}'}';
  }

  static String remotePending({
    required bool isAdmin,
    String? fromDate,
    String? toDate,
    String? status,
  }) {
    final params = <String>[
      if (fromDate != null && fromDate.isNotEmpty) 'from_date=$fromDate',
      if (toDate != null && toDate.isNotEmpty) 'to_date=$toDate',
      if (status != null && status.isNotEmpty) 'status=$status',
    ];
    final path = isAdmin ? 'admin/pending' : 'team-lead/pending';
    return '$remoteWorkBase/$path${params.isEmpty ? '' : '?${params.join('&')}'}';
  }

  static String remoteDecision({required String id, required bool isAdmin}) =>
      '$remoteWorkBase/$id/${isAdmin ? 'admin-approval' : 'team-lead-approval'}';

  static String playStoreURL = '';
  static String appStoreURL = '';

  static void updateBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      baseUrl = newUrl;
      print("🔹 Base URL updated to: $baseUrl");
    }
  }
}
