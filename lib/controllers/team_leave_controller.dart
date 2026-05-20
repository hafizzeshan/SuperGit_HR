import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/team_leave_request_model.dart';
import 'package:supergithr/network/repository/attendance_repo/team_leave_repo.dart';

class TeamLeaveController extends GetxController {
  final TeamLeaveRepository _repo = TeamLeaveRepository();

  // Authorization flags (loaded from prefs, set at login)
  final RxBool isManager = false.obs;
  final RxBool isDepartmentHead = false.obs;
  String _employeeId = '';

  // Feed state
  final RxList<TeamLeaveRequest> requests = <TeamLeaveRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt page = 1.obs;
  final RxInt total = 0.obs;
  final int limit = 10;

  // Per-request action flags (keyed by request id)
  final RxnString processingId = RxnString();

  bool get canReview => isManager.value || isDepartmentHead.value;
  bool get hasMore => requests.length < total.value;

  @override
  void onInit() {
    super.onInit();
    loadAuth();
  }

  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    isManager.value = prefs.getBool('is_manager') ?? false;
    isDepartmentHead.value = prefs.getBool('is_department_head') ?? false;
    _employeeId = prefs.getString('employee_id') ?? '';
  }

  Future<void> fetchRequests({bool refresh = true}) async {
    if (!canReview) return;
    if (_employeeId.isEmpty) await loadAuth();
    if (_employeeId.isEmpty) return;

    if (refresh) {
      isLoading.value = true;
      page.value = 1;
    } else {
      if (isLoadingMore.value || !hasMore) return;
      isLoadingMore.value = true;
    }

    try {
      final res = await _repo.getTeamRequests(
        currentApproverId: _employeeId,
        page: page.value,
        limit: limit,
      );
      if (res != null) {
        final list =
            (res['data'] as List? ?? [])
                .map(
                  (e) => TeamLeaveRequest.fromMap(Map<String, dynamic>.from(e)),
                )
                .toList();
        total.value =
            (res['total'] is num) ? (res['total'] as num).toInt() : list.length;
        if (refresh) {
          requests.assignAll(list);
        } else {
          requests.addAll(list);
        }
      }
    } catch (e, st) {
      log("❌ fetchRequests: $e", stackTrace: st);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore) return;
    page.value += 1;
    await fetchRequests(refresh: false);
  }

  Future<bool> approve(String id, {String? remarks}) async {
    processingId.value = id;
    try {
      final ok = await _repo.approve(id, remarks: remarks);
      if (ok) _removeLocally(id);
      return ok;
    } finally {
      processingId.value = null;
    }
  }

  Future<bool> reject(String id, {String? remarks}) async {
    processingId.value = id;
    try {
      final ok = await _repo.reject(id, remarks: remarks);
      if (ok) _removeLocally(id);
      return ok;
    } finally {
      processingId.value = null;
    }
  }

  void _removeLocally(String id) {
    requests.removeWhere((r) => r.id == id);
    if (total.value > 0) total.value -= 1;
  }
}
