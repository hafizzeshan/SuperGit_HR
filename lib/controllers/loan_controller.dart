import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/loan_model.dart';
import 'package:supergithr/network/repository/loan_repo/loan_repo.dart';
import 'package:supergithr/utils/utils.dart';

class LoanController extends GetxController {
  final LoanRepository _repo = LoanRepository();

  /// Observables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var loans = <LoanDatum>[].obs;

  /// Form controllers
  final amountController = TextEditingController();
  final purposeController = TextEditingController();
  final installmentsController = TextEditingController();
  final startMonthController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Don't fetch here - loans will be fetched in splash screen
  }

  /// ✅ Fetch Employee Loans
  Future<void> fetchLoans() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";
      final token = prefs.getString('authToken') ?? "";

      if (token.isEmpty) {
        print("🔹 Auth token not found in preferences.");
        // Utils.snackBar("Auth token not found. Please log in again.", true);
        return;
      }

      if (employeeId.isEmpty) {
        print("🔹 Employee ID not found in preferences.");

        Utils.snackBar("Employee ID not found. Please log in again.", true);
        return;
      }
      final response = await _repo.getEmployeeLoans(
        employeeId,
      ); // Replace with dynamic employeeId
      if (response != null && response["data"] != null) {
        final List<LoanDatum> loanList =
            (response["data"] as List)
                .map((e) => LoanDatum.fromJson(e))
                .toList();
        loans.assignAll(loanList);
        print("✅ Loans fetched: ${loans.length}");
      } else {
        Utils.snackBar("Failed to fetch loans", true);
      }
    } catch (e) {
      isLoading.value = false;

      Utils.snackBar("Error fetching loans: $e", true);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Apply for a Loan (Updated to match your payload)
  Future<void> applyLoan() async {
    final amount = amountController.text.trim();
    final purpose = purposeController.text.trim();
    final installments = installmentsController.text.trim();
    final startMonth = startMonthController.text.trim();
    print(
      "Applying for loan with small data: {amount: $amount, purpose: $purpose, installments: $installments, startMonth: $startMonth}",
    );

    if (amount.isEmpty ||
        purpose.isEmpty ||
        installments.isEmpty ||
        startMonth.isEmpty) {
      Utils.snackBar("Please fill all required fields", true);
      return;
    }

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        return;
      }
      final data = {
        "employee_id": employeeId, // Replace with actual employee id
        "amount": double.tryParse(amount) ?? 0.0,
        "purpose": purpose,
        "installments": int.tryParse(installments) ?? 0,
        "monthly_installment":
            (double.tryParse(amount) ?? 0.0) /
            (int.tryParse(installments) ?? 1),
        "remaining_amount": double.tryParse(amount) ?? 0.0,
        "start_month": startMonth,
      };
      print("Applying for loan with data: $data");

      final response = await _repo.applyLoan(data);

      if (response != null) {
        isSubmitting.value = false;
        // Snackbar is already shown in repository, no need to show again
        // Insert at the beginning of the list (index 0) to show at top
        loans.insert(0, LoanDatum.fromJson(response));
        Get.back();
        clearForm();
      } else {
        isSubmitting.value = false;
        // Error snackbar is already shown in repository
      }
    } catch (e) {
      isSubmitting.value = false;
      // Error snackbar is already shown in repository
    }
  }

  /// ✅ Clear Form Fields
  void clearForm() {
    amountController.clear();
    purposeController.clear();
    installmentsController.clear();
    startMonthController.clear();
  }

  @override
  void onClose() {
    amountController.dispose();
    purposeController.dispose();
    installmentsController.dispose();
    startMonthController.dispose();
    super.onClose();
  }
}
