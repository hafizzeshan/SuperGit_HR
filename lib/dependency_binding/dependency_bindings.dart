import 'package:get/get.dart';
import 'package:supergithr/controllers/announcement_controller.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/document_controller.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/controllers/holiday_controller.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/controllers/login_controller.dart';
import 'package:supergithr/controllers/salary_structure_controller.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/controllers/register_controller.dart';

class DependencyBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController());
    Get.put(AttendanceController());
    Get.put(LeaveController());
    Get.put(LoginController());
    Get.put(RegisterController());
    Get.put(AttendanceHistoryController());
    Get.put(LocationController());
    Get.put(DocumentController());
    Get.put(SalaryStructureController());
    Get.put(LoanController());
    Get.put(HolidayController());
    Get.put(AnnouncementController());
  }
}
