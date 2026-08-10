import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AirTicketRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// Extract `data` from the standardised `{success, message, data}` envelope.
  dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  /// GET /air-tickets/entitlements/{employee_id}?year=YYYY
  Future<Map<String, dynamic>?> getEntitlement({
    required String employeeId,
    int? year,
  }) async {
    try {
      final url = AppURL.airTicketEntitlement(employeeId, year: year);
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

  /// GET /air-tickets/entitlements/{employee_id}/all
  Future<List<dynamic>?> getAllEntitlements(String employeeId) async {
    try {
      final url = AppURL.airTicketAllEntitlements(employeeId);
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

  /// POST /air-tickets/requests
  Future<Map<String, dynamic>?> createRequest(Map<String, dynamic> data) async {
    try {
      final url = AppURL.airTicketCreateRequest();
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

  /// GET /air-tickets/requests?employee_id=...&status=...&page=...&limit=...
  Future<Map<String, dynamic>?> getRequests({
    String? employeeId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = AppURL.airTicketRequests(
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

  /// GET /air-tickets/requests/{request_id}
  Future<Map<String, dynamic>?> getRequestDetails(String requestId) async {
    try {
      final url = AppURL.airTicketRequestDetails(requestId);
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

  /// DELETE /air-tickets/requests/{request_id}
  Future<bool> cancelRequest(String requestId) async {
    try {
      final url = AppURL.airTicketCancelRequest(requestId);
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

  /// GET /air-tickets/requests/{request_id}/booking
  Future<Map<String, dynamic>?> getBooking(String requestId) async {
    try {
      final url = AppURL.airTicketBooking(requestId);
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
