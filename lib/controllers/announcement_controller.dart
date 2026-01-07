import 'package:get/get.dart';
import 'package:supergithr/models/announcement_model.dart';
import 'package:supergithr/network/repository/announcement_repo.dart';

class AnnouncementController extends GetxController {
  final AnnouncementRepository _repo = AnnouncementRepository();
  final RxList<AnnouncementData> announcements = <AnnouncementData>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchAnnouncements();
    super.onInit();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    try {
      final response = await _repo.getAnnouncements();
      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        announcements.assignAll(
          data.map((json) => AnnouncementData.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print("Error fetching announcements: $e");
    } finally {
      isLoading.value = false;
    }
  }

  AnnouncementData? get latestAnnouncement {
    if (announcements.isEmpty) return null;
    // Assuming the API returns them in descending order (latest first)
    return announcements.first;
  }
}
