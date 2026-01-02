import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AttendanceRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Clock In API
  Future clockIn({required data}) async {
    try {
      final response = await _api.postRequest(AppURL.clockInApi, data: data);

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Clock-In Response: ${response.data}");
        Utils.snackBar(
          response.data?['message'] ?? "Clock-In Successful!",
          false,
        );
        return response.data;
      } else {
        final message = response.data?['message'] ?? "Clock-In failed";
        Utils.snackBar(message, true);
        log("❌ Clock-In Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in Clock-In: $e", stackTrace: st);
      Utils.snackBar("Something went wrong during Clock-In", true);
      return null;
    }
  }

  /// ✅ Clock Out API
  Future clockOut({required data}) async {
    try {
      final response = await _api.postRequest(AppURL.clockOutApi, data: data);

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Clock-Out Response: ${response.data}");
        Utils.snackBar(
          response.data?['message'] ?? "Clock-Out Successful!",
          false,
        );
        return response.data;
      } else {
        final message = response.data?['message'] ?? "Clock-Out failed";
        Utils.snackBar(message, true);
        log("❌ Clock-Out Failed: $message");
      }
    } catch (e, st) {
      log("❌ Exception in Clock-Out: $e", stackTrace: st);
      Utils.snackBar("Something went wrong during Clock-Out", true);
    }
  }
}
