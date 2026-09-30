import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

/// Remote work clock-in/out and the two approval queues.
///
/// Same host as ethics reports (hr2), so every call is an absolute URL with
/// the tenant header attached.
class RemoteWorkRepository {
  final ApiNetworkService _api = ApiNetworkService();

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final tenantId = prefs.getString('tenant_id') ?? '';
    return {if (tenantId.isNotEmpty) 'X-Tenant-ID': tenantId};
  }

  Map<String, dynamic>? _body(Response? response) {
    if (response == null) return null;
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      log(
        '❌ Remote work API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> clockIn({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.postRequest(
      AppURL.remoteClockIn,
      data: {'latitude': latitude, 'longitude': longitude},
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> clockOut({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.postRequest(
      AppURL.remoteClockOut,
      data: {'latitude': latitude, 'longitude': longitude},
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> mySessions({
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _api.getRequest(
      AppURL.remoteMySessions(fromDate: fromDate, toDate: toDate),
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> pendingApprovals({
    required bool isAdmin,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    final response = await _api.getRequest(
      AppURL.remotePending(
        isAdmin: isAdmin,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
      ),
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<bool> decide({
    required String id,
    required bool isAdmin,
    required bool approved,
    String remarks = '',
  }) async {
    final response = await _api.putRequest(
      AppURL.remoteDecision(id: id, isAdmin: isAdmin),
      data: {
        'approved': approved,
        if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
      },
      headers: await _headers(),
      usePatch: true,
    );
    return _body(response) != null;
  }
}
