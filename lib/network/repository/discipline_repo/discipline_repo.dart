import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

/// Discipline incidents and warning letters (hr2 service).
class DisciplineRepository {
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
        '❌ Discipline API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // ── employee ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> myIncidents({
    int page = 1,
    int pageSize = 20,
  }) async => _body(
    await _api.getRequest(
      AppURL.disciplineMyIncidents(page: page, pageSize: pageSize),
      headers: await _headers(),
    ),
  );

  Future<Map<String, dynamic>?> myWarnings() async => _body(
    await _api.getRequest(
      AppURL.disciplineMyWarnings,
      headers: await _headers(),
    ),
  );

  /// Submitting (or editing) an explanation moves the incident to
  /// "Under Review" on the server.
  Future<Map<String, dynamic>?> submitJustification({
    required String incidentId,
    required String justification,
  }) async => _body(
    await _api.postRequest(
      AppURL.disciplineJustification(incidentId),
      data: {'justification': justification},
      headers: await _headers(),
    ),
  );

  // ── admin ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> incidents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? employeeId,
  }) async => _body(
    await _api.getRequest(
      AppURL.disciplineIncidentsList(
        page: page,
        pageSize: pageSize,
        status: status,
        employeeId: employeeId,
      ),
      headers: await _headers(),
    ),
  );

  Future<Map<String, dynamic>?> updateIncident(
    String id,
    Map<String, dynamic> data,
  ) async => _body(
    await _api.putRequest(
      AppURL.disciplineIncident(id),
      data: data,
      headers: await _headers(),
    ),
  );

  Future<bool> changeStatus({
    required String id,
    required String status,
  }) async =>
      _body(
        await _api.putRequest(
          AppURL.disciplineIncidentStatus(id),
          data: {'status': status},
          headers: await _headers(),
          usePatch: true,
        ),
      ) !=
      null;

  /// Final determination: "Valid" confirms, "Invalid" rejects.
  Future<bool> review({
    required String id,
    required String disposition,
    required String comments,
  }) async =>
      _body(
        await _api.postRequest(
          AppURL.disciplineIncidentReview(id),
          data: {'disposition': disposition, 'comments': comments},
          headers: await _headers(),
        ),
      ) !=
      null;

  Future<bool> deleteIncident(String id) async =>
      _body(
        await _api.deleteRequest(
          AppURL.disciplineIncident(id),
          headers: await _headers(),
        ),
      ) !=
      null;

  Future<Map<String, dynamic>?> eligibility(String employeeId) async => _body(
    await _api.getRequest(
      AppURL.disciplineEligibility(employeeId),
      headers: await _headers(),
    ),
  );

  Future<Map<String, dynamic>?> warnings({
    int page = 1,
    int pageSize = 20,
  }) async => _body(
    await _api.getRequest(
      AppURL.disciplineWarningsList(page: page, pageSize: pageSize),
      headers: await _headers(),
    ),
  );

  Future<Map<String, dynamic>?> createWarning(
    Map<String, dynamic> data,
  ) async => _body(
    await _api.postRequest(
      AppURL.disciplineWarnings,
      data: data,
      headers: await _headers(),
    ),
  );

  Future<bool> deleteWarning(String id) async =>
      _body(
        await _api.deleteRequest(
          AppURL.disciplineWarning(id),
          headers: await _headers(),
        ),
      ) !=
      null;
}
