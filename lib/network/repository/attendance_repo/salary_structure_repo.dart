import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
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
        Utils.snackBar(TranslationKeys.unableToReachServerShort.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Salary Structure Data Fetched for Employee $employeeId");
        return response.data;
      } else {
        Utils.snackBar(TranslationKeys.failedToFetchSalaryStructure.tr, true);
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getSalaryStructureList: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.errorLoadingSalaryStructure.tr, true);
      return null;
    }
  }
}
