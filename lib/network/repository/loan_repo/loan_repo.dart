import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class LoanRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Get Employee Loans
  Future getEmployeeLoans(String employeeId) async {
    try {
      final response = await _api.getRequest(AppURL.loanApi(employeeId));

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        final message = response.data?['message'] ?? "Failed to fetch loans";
        Utils.snackBar(message, true);
        log("❌ Loans Fetch Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in getEmployeeLoans: $e", stackTrace: st);
      Utils.snackBar("Something went wrong while fetching loans", true);
      return null;
    }
  }

  /// ✅ Apply for a loan (Updated payload)
  Future applyLoan(Map<String, dynamic> data) async {
    try {
      final response = await _api.postRequest(AppURL.loanApplyApi, data: data);

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Loan Application Response: ${response.data}");
        Utils.snackBar(
          response.data?['message'] ?? "Loan applied successfully!",
          false,
        );
        return response.data;
      } else {
        final message = response.data?['message'] ?? "Loan application failed";
        Utils.snackBar(message, true);
        log("❌ Loan Application Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in applyLoan: $e", stackTrace: st);
      Utils.snackBar("Something went wrong while applying for loan", true);
      return null;
    }
  }
}
