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

  static String playStoreURL = '';
  static String appStoreURL = '';

  static void updateBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      baseUrl = newUrl;
      print("🔹 Base URL updated to: $baseUrl");
    }
  }
}
