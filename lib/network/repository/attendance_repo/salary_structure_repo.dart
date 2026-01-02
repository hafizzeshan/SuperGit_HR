import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class SalaryStructureRepository {
  final ApiNetworkService _api = ApiNetworkService();

  Future getSalaryStructureList({required String employeeId}) async {
    try {
      final url = "${AppURL.salaryStructureApi}/$employeeId";

      final response = await _api.getRequest(url);

      if (response == null) {
        Utils.snackBar("Unable to reach server.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Salary Structure Data Fetched for Employee $employeeId");
        return response.data;
      } else {
        Utils.snackBar("Failed to fetch salary structure", true);
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getSalaryStructureList: $e", stackTrace: st);
      Utils.snackBar("Error loading salary structure", true);
      return null;
    }
  }
}
