import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AirTicketRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// Resolve the tenant id saved at login. Returns empty string if missing —
  /// caller should bail out in that case.
  Future<String> _tenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tenant_id') ?? '';
  }

  /// Extract `data` from the standardised `{success, message, data}` envelope.
  dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  /// 1.1 GET /entitlements/{employee_id}?year=YYYY
  Future<Map<String, dynamic>?> getEntitlement({
    required String employeeId,
    int? year,
  }) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketEntitlement(tenantId, employeeId, year: year);
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to load entitlement"), true);
      return null;
    } catch (e, st) {
      log("❌ getEntitlement: $e", stackTrace: st);
      return null;
    }
  }

  /// 1.2 GET /entitlements/{employee_id}/all
  Future<List<dynamic>?> getAllEntitlements(String employeeId) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketAllEntitlements(tenantId, employeeId);
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is List ? data : null;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to load entitlements"), true);
      return null;
    } catch (e, st) {
      log("❌ getAllEntitlements: $e", stackTrace: st);
      return null;
    }
  }

  /// 2.1 POST /requests
  Future<Map<String, dynamic>?> createRequest(Map<String, dynamic> data) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketCreateRequest(tenantId);
      final res = await _api.postRequest(url, data: data);
      if (res == null) return null;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Utils.snackBar(
          res.data?['message'] ?? "Air ticket request created",
          false,
        );
        final body = _unwrap(res.data);
        return body is Map<String, dynamic> ? body : null;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to create request"), true);
      return null;
    } catch (e, st) {
      log("❌ createRequest: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongSubmittingRequest.tr, true);
      return null;
    }
  }

  /// 2.2 GET /requests
  Future<Map<String, dynamic>?> getRequests({
    String? employeeId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketRequests(
        tenantId,
        employeeId: employeeId,
        status: status,
        page: page,
        limit: limit,
      );
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to load requests"), true);
      return null;
    } catch (e, st) {
      log("❌ getRequests: $e", stackTrace: st);
      return null;
    }
  }

  /// 2.3 GET /requests/{request_id}
  Future<Map<String, dynamic>?> getRequestDetails(String requestId) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketRequestDetails(tenantId, requestId);
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to load details"), true);
      return null;
    } catch (e, st) {
      log("❌ getRequestDetails: $e", stackTrace: st);
      return null;
    }
  }

  /// 2.4 DELETE /requests/{request_id}?employee_id=...
  Future<bool> cancelRequest({
    required String requestId,
    required String employeeId,
  }) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return false;
      final url = AppURL.airTicketCancelRequest(tenantId, requestId, employeeId);
      final res = await _api.deleteRequest(url);
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 204) {
        Utils.snackBar(
          res.data?['message'] ?? "Request cancelled",
          false,
        );
        return true;
      }
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to cancel request"), true);
      return false;
    } catch (e, st) {
      log("❌ cancelRequest: $e", stackTrace: st);
      return false;
    }
  }

  /// 4.2 GET /requests/{request_id}/booking
  Future<Map<String, dynamic>?> getBooking(String requestId) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;
      final url = AppURL.airTicketBooking(tenantId, requestId);
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      // 404 = no booking yet, don't show snackbar
      if (res.statusCode == 404) return null;
      Utils.snackBar(Utils.extractApiError(res.data, "Failed to load booking"), true);
      return null;
    } catch (e, st) {
      log("❌ getBooking: $e", stackTrace: st);
      return null;
    }
  }
}
