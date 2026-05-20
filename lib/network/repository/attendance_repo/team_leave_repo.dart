import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class TeamLeaveRepository {
  final ApiNetworkService _api = ApiNetworkService();

  String _errorMessage(dynamic body, String fallback) {
    if (body is Map) {
      final m = body['message'] ?? body['error'];
      if (m is String && m.isNotEmpty) return m;
    }
    return fallback;
  }

  /// GET /leave/requests?status=PendingManager&current_approver_id=...
  /// Returns the full body so the caller can read data + pagination.
  Future<Map<String, dynamic>?> getTeamRequests({
    required String currentApproverId,
    String status = 'PendingManager',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = AppURL.teamLeaveRequests(
        currentApproverId: currentApproverId,
        status: status,
        page: page,
        limit: limit,
      );
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        return res.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(res.data)
            : null;
      }
      Utils.snackBar(
        _errorMessage(res.data, "Failed to load leave requests"),
        true,
      );
      return null;
    } catch (e, st) {
      log("❌ getTeamRequests: $e", stackTrace: st);
      return null;
    }
  }

  /// PUT /leave/requests/{id}/manager-approve
  Future<bool> approve(String id, {String? remarks}) async {
    try {
      final res = await _api.putRequest(
        AppURL.teamLeaveApprove(id),
        data: {if (remarks != null && remarks.isNotEmpty) 'remarks': remarks},
      );
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ??
              "Leave request approved",
          false,
        );
        return true;
      }
      Utils.snackBar(
        _errorMessage(res.data, "Failed to approve request"),
        true,
      );
      return false;
    } catch (e, st) {
      log("❌ approve: $e", stackTrace: st);
      return false;
    }
  }

  /// PUT /leave/requests/{id}/reject
  Future<bool> reject(String id, {String? remarks}) async {
    try {
      final res = await _api.putRequest(
        AppURL.teamLeaveReject(id),
        data: {if (remarks != null && remarks.isNotEmpty) 'remarks': remarks},
      );
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ??
              "Leave request rejected",
          false,
        );
        return true;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to reject request"), true);
      return false;
    } catch (e, st) {
      log("❌ reject: $e", stackTrace: st);
      return false;
    }
  }
}
