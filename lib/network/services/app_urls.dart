class AppURL {
  // shamas
  // static const String baseUrl = 'https://jzq6qslp-8080.asse.devtunnels.ms/api/';
  // live (default — can be overridden by Firebase Remote Config)
  static String baseUrl = 'https://hr1.api.supergitsa.com/api/';

  static String attendanceHistory(
    String employeeId,
    String startDate,
    String endDate,
  ) =>
      "${baseUrl}attendance/history?employee_id=$employeeId&start_date=$startDate&end_date=$endDate";

  static const String loginApi = 'auth/login';
  static const String updateProfile = 'update-profile';

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

  static String employeeDocuments(String id) {
    return 'employees/$id/documents';
  }

  static String getProfile(v) {
    return 'employees/$v';
  }

  // ✈️ Air Ticket APIs (tenant-scoped)
  static String airTicketsBase(String tenantId) =>
      'v1/tenant/$tenantId/air-tickets';

  static String airTicketEntitlement(String tenantId, String employeeId, {int? year}) {
    final base = '${airTicketsBase(tenantId)}/entitlements/$employeeId';
    return year != null ? '$base?year=$year' : base;
  }

  static String airTicketAllEntitlements(String tenantId, String employeeId) =>
      '${airTicketsBase(tenantId)}/entitlements/$employeeId/all';

  static String airTicketRequests(
    String tenantId, {
    String? employeeId,
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (employeeId != null && employeeId.isNotEmpty) {
      params['employee_id'] = employeeId;
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${airTicketsBase(tenantId)}/requests?$query';
  }

  static String airTicketCreateRequest(String tenantId) =>
      '${airTicketsBase(tenantId)}/requests';

  static String airTicketRequestDetails(String tenantId, String requestId) =>
      '${airTicketsBase(tenantId)}/requests/$requestId';

  static String airTicketCancelRequest(
    String tenantId,
    String requestId,
    String employeeId,
  ) =>
      '${airTicketsBase(tenantId)}/requests/$requestId?employee_id=$employeeId';

  static String airTicketBooking(String tenantId, String requestId) =>
      '${airTicketsBase(tenantId)}/requests/$requestId/booking';

  static String playStoreURL = '';
  static String appStoreURL = '';

  static void updateBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      baseUrl = newUrl;
      print("🔹 Base URL updated to: $baseUrl");
    }
  }
}
