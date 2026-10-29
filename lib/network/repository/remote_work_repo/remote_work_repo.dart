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


  /// Last message the service returned for a failed call, so the controller
  /// can show what actually went wrong ("remote clock-in already exists for
  /// today") instead of a generic failure.
  String lastError = '';

  /// Reads the message out of an error body, in the order the service uses.
  static String _messageOf(dynamic data) {
    if (data is String) return data.trim();
    if (data is! Map) return '';
    for (final key in ['message', 'error', 'msg', 'detail', 'details']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map && v['message'] is String) return '${v['message']}'.trim();
      if (v is List && v.isNotEmpty) return '${v.first}'.trim();
    }
    return '';
  }

  Map<String, dynamic>? _body(Response? response) {
    if (response == null) {
      lastError = '';
      return null;
    }
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      lastError = _messageOf(response.data);
      log(
        '❌ Remote work API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
    lastError = '';
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
