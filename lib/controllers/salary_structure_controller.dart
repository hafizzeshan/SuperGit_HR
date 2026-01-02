import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/salary_structure_model.dart';
import 'package:supergithr/utils/utils.dart';

import '../network/repository/attendance_repo/salary_structure_repo.dart';

class SalaryStructureController extends GetxController {
  final _repo = SalaryStructureRepository();
  var salaryStructureList = <SalaryDatum>[].obs;

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;

  @override
  void onInit() {
    // fetchSalaryStructureList();
    super.onInit();
  }

  Future<void> fetchSalaryStructureList({bool loadMore = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('employee_id') ?? "";

    if (employeeId.isEmpty) {
      Utils.snackBar("Employee ID not found. Please log in again.", true);
      return;
    }

    // ---------------------------
    // If NOT loading more → Reset list
    // ---------------------------
    if (!loadMore) {
      isLoading.value = true;
      salaryStructureList.clear(); // 🔥 FIX → Prevent duplicates
      currentPage = 1; // Reset page
      hasMore = true; // Enable pagination again
    } else {
      if (!hasMore) return; // No more pages
      isMoreLoading.value = true;
    }

    try {
      final response = await _repo.getSalaryStructureList(
        employeeId: employeeId,
      );

      if (response == null) return;

      final List items = response["data"] ?? [];

      // ---------------------------
      // Append only NEW data
      // ---------------------------
      final newItems = items.map((e) => SalaryDatum.fromJson(e)).toList();

      if (newItems.isEmpty) {
        hasMore = false;
      } else {
        salaryStructureList.addAll(newItems);
        currentPage++;
      }

      // ---------------------------
      // Stop if reached last page
      // ---------------------------
      final totalPages = response["totalPages"] ?? 1;
      hasMore = currentPage <= totalPages;
    } catch (e) {
      Utils.snackBar("Error loading salary structure", true);
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }
}
