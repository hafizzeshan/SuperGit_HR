class AppURL {
  // static const String baseUrl =
  //     'https://his2.api.supergitsa.com/mobile/api/v1/';
  // live
  // static const String baseUrl =
  //     'https://mobile1.api.supergitsa.com/mobile/api/v1/';
  // shamas
  // static const String baseUrl = 'https://6d5rc5cb-8080.inc1.devtunnels.ms/api/';
  // live
  // static const String baseUrl = 'https://hr1.api.supergitsa.com/api/';
  static const String baseUrl = 'https://90j4c2m1-8080.asse.devtunnels.ms/api/';

  static const String loginApi = 'auth/login';
  static const String updateProfile = 'update-profile';
  static const String getBusiness = 'business/list';
  static const String getBranch = 'branch/list';
  static const String getDepartment = 'department/getList';

  static const String getDepartmentByIdd = 'practitioner/getByDepartment';
  static const String getDoctorSlots = 'visit/getPractitionerSlots';
  static const String createAppointment = 'appointment/create';
  static const String business = 'business/list';

  static const String registerApi = 'register';
  static const String otpVerificationApi = 'verify_otp';
  static const String forgotPasswordApi = 'recover-password';
  static const String veriftyOTP = 'verifyPass-otp';

  static const String confirmForgotPasswordApi = 'recover-password-confirm';
  static const String logOutApi = '/logout';
  static const String visitsToday = '/visit/getPatientVisitById';
  static const String forms = '/form/all?request_type=visit';
  static const String submitDynamicForm = '/visit/internal-result-upload';

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

  // loan APIs
  static String loanApi(v) {
    return 'payroll/loans/employee/$v';
  }

  static const String loanApplyApi = 'payroll/loans';

  static String category(v) {
    return '/category/all/$v?request_type=visit';
  }

  static String leaveHistory(v) {
    return 'employees/$v/leaves';
  }

  static String employeeDocuments(String id) {
    return 'employees/$id/documents';
  }

  static String getProfile(v) {
    return 'employees/$v';
  }

  static String playStoreURL =
      'https://play.google.com/store/apps/details?id=com.groomifysa';
  static String appStoreURL =
      'https://https://www.apple.com/app-store/?id=com.bytes.groomify';

  static void updateBaseUrl(String? newUrl) {
    //  baseUrl = newUrl ?? "https://fairly-notable-koala.ngrok-free.app/api/v3";
  }

  // static void updateAppURL({
  //   required String? playStore,
  //   required String? appStore,
  // }) {
  //   playStoreURL =
  //       playStore ??
  //       "https://play.google.com/store/apps/details?id=com.groomifysa";
  //   appStoreURL =
  //       appStore ??
  //       "https://https://www.apple.com/app-store/?id=com.bytes.groomify";
  // }
}
