import 'package:get/get.dart';
import 'package:supergithr/models/holiday_model.dart';
import 'package:supergithr/network/repository/attendance_repo/holiday_repo.dart';
import 'package:supergithr/utils/utils.dart';

class HolidayController extends GetxController {
  final _repo = HolidayRepository();
  var holidays = <HolidaDatum>[].obs;

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  @override
  void onInit() {
    // Don't fetch here - holidays will be fetched in splash screen
    super.onInit();
  }

  /// Fetch Holidays List from Repository
  Future<void> fetchHolidays({bool loadMore = false}) async {
    isLoading.value = true;

    // If not loading more → Reset the list
    if (!loadMore) {
      holidays.clear();
      currentPage = 1;
      hasMore = true;
    } else {
      if (!hasMore) return; // No more holidays left to load
      isMoreLoading.value = true;
    }

    try {
      final response = await _repo.getHolidays(
        page: currentPage,
        pageSize: pageSize,
      );

      if (response == null) return;

      final List items = response["data"] ?? [];

      // Add new items to the holiday list
      final newHolidays = items.map((e) => HolidaDatum.fromJson(e)).toList();

      if (newHolidays.isEmpty) {
        hasMore = false;
      } else {
        holidays.addAll(newHolidays);
        currentPage++;
      }

      final totalPages = response["totalPages"] ?? 1;
      if (currentPage > totalPages) {
        hasMore = false;
      }
    } catch (e) {
      Utils.snackBar("Error fetching holidays: $e", true);
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }
}
