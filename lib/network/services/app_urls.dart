class AppURL {
  // shamas
  // static const String baseUrl = 'https://jzq6qslp-8080.asse.devtunnels.ms/api/';
  // live (default — can be overridden by Firebase Remote Config)
  // The compile-time default. Used to restore the URL when the Remote Config
  // override is turned off from the app.
  static const String defaultBaseUrl = 'https://hr1.api.supergitsa.com/api/';
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

  static String playStoreURL = '';
  static String appStoreURL = '';

  static void updateBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      baseUrl = newUrl;
      print("🔹 Base URL updated to: $baseUrl");
    }
  }
}
