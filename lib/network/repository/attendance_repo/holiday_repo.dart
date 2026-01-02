import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class HolidayRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// Fetch Holidays List
  Future getHolidays({required int page, required int pageSize}) async {
    try {
      final url = "${AppURL.holidayApi}?page=$page&page_size=$pageSize";
      final response = await _api.getRequest(url);

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Holiday Data Fetched");
        return response.data; // Holiday data
      } else {
        Utils.snackBar("Failed to fetch holidays", true);
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getHolidays: $e", stackTrace: st);
      Utils.snackBar("Error loading holidays", true);
      return null;
    }
  }
}
