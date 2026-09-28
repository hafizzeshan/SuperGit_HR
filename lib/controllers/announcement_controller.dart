import 'package:get/get.dart';
import 'package:supergithr/models/announcement_model.dart';
import 'package:supergithr/network/repository/announcement_repo.dart';

class AnnouncementController extends GetxController {
  final AnnouncementRepository _repo = AnnouncementRepository();
  final RxList<AnnouncementData> announcements = <AnnouncementData>[].obs;
  final RxBool isLoading = false.obs;

  /// True once a fetch has finished, successfully or not. Drives the shimmer:
  /// it is only shown before the very first result arrives.
  final RxBool hasLoadedOnce = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Skips the network call when announcements are already in hand. Pass
  /// [force] for pull-to-refresh, which should always re-read.
  Future<void> fetchAnnouncements({bool force = false}) async {
    if (hasLoadedOnce.value && !force) return;
    if (isLoading.value) return; // a fetch is already in flight
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
      hasLoadedOnce.value = true;
    }
  }

  AnnouncementData? get latestAnnouncement {
    if (announcements.isEmpty) return null;
    // Assuming the API returns them in descending order (latest first)
    return announcements.first;
  }
}
