import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AnnouncementRepository {
  final ApiNetworkService _api = ApiNetworkService();

  Future getAnnouncements() async {
    try {
      final response = await _api.getRequest(AppURL.announcementApi);

      if (response == null) {
        // Utils.snackBar("Unable to reach server.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Announcements Fetched Successfully");
        return response.data;
      } else {
        // Utils.snackBar("Failed to fetch announcements", true);
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getAnnouncements: $e", stackTrace: st);
      // Utils.snackBar("Error loading announcements", true);
      return null;
    }
  }
}
