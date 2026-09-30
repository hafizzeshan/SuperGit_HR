import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/discipline_model.dart';
import 'package:supergithr/network/repository/discipline_repo/discipline_repo.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/utils.dart';

class DisciplineController extends GetxController {
  final DisciplineRepository _repo = DisciplineRepository();

  // ── employee ───────────────────────────────────────────────────────────
  final myIncidents = <DisciplineIncident>[].obs;
  final myWarnings = <DisciplineWarning>[].obs;
  final isLoadingIncidents = false.obs;
  final isLoadingWarnings = false.obs;
  final hasLoadedIncidents = false.obs;
  final hasLoadedWarnings = false.obs;
  final isSubmitting = false.obs;

  // ── admin ──────────────────────────────────────────────────────────────
  final allIncidents = <DisciplineIncident>[].obs;
  final allWarnings = <DisciplineWarning>[].obs;
  final isLoadingAdmin = false.obs;
  final statusFilter = Rxn<IncidentStatus>();
  final busyId = ''.obs;
  final eligibility = Rxn<WarningEligibility>();
  final isCheckingEligibility = false.obs;

  /// Only confirmed incidents can carry a warning letter.
  List<DisciplineIncident> get confirmedIncidents =>
      allIncidents.where((i) => i.status == IncidentStatus.confirmed).toList();

  @override
  void onInit() {
    super.onInit();
    loadMyIncidents();
    loadMyWarnings();
  }

  List<T> _parseList<T>(
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) build,
  ) {
    final raw = body?['data'];
    if (raw is! List) return <T>[];
    return raw
        .whereType<Map>()
        .map((e) => build(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── employee actions ───────────────────────────────────────────────────

  Future<void> loadMyIncidents({bool force = false}) async {
    if (hasLoadedIncidents.value && !force) return;
    if (isLoadingIncidents.value) return;
    try {
      isLoadingIncidents.value = true;
      myIncidents.assignAll(
        _parseList(await _repo.myIncidents(), DisciplineIncident.fromJson),
      );
    } finally {
      isLoadingIncidents.value = false;
      hasLoadedIncidents.value = true;
    }
  }

  Future<void> loadMyWarnings({bool force = false}) async {
    if (hasLoadedWarnings.value && !force) return;
    if (isLoadingWarnings.value) return;
    try {
      isLoadingWarnings.value = true;
      myWarnings.assignAll(
        _parseList(await _repo.myWarnings(), DisciplineWarning.fromJson),
      );
    } finally {
      isLoadingWarnings.value = false;
      hasLoadedWarnings.value = true;
    }
  }

  Future<bool> submitJustification({
    required String incidentId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      Utils.snackBar(TranslationKeys.pleaseEnterYourMessage.tr, true);
      return false;
    }
    try {
      isSubmitting.value = true;
      final body = await _repo.submitJustification(
        incidentId: incidentId,
        justification: text.trim(),
      );
      if (body == null) {
        Utils.snackBar(TranslationKeys.failedToSubmitReport.tr, true);
        return false;
      }
      await loadMyIncidents(force: true);
      Utils.snackBar(TranslationKeys.justificationSubmitted.tr, false);
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── admin actions ──────────────────────────────────────────────────────

  Future<void> loadAdminIncidents({bool force = false}) async {
    if (isLoadingAdmin.value) return;
    try {
      isLoadingAdmin.value = true;
      allIncidents.assignAll(
        _parseList(
          await _repo.incidents(
            status:
                statusFilter.value == null
                    ? null
                    : DisciplineEnums.statusValue(statusFilter.value!),
            pageSize: 50,
          ),
          DisciplineIncident.fromJson,
        ),
      );
    } finally {
      isLoadingAdmin.value = false;
    }
  }

  void setStatusFilter(IncidentStatus? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadAdminIncidents(force: true);
  }

  Future<void> loadAdminWarnings({bool force = false}) async {
    if (isLoadingAdmin.value) return;
    try {
      isLoadingAdmin.value = true;
      allWarnings.assignAll(
        _parseList(
          await _repo.warnings(pageSize: 50),
          DisciplineWarning.fromJson,
        ),
      );
    } finally {
      isLoadingAdmin.value = false;
    }
  }

  Future<void> changeStatus({
    required DisciplineIncident incident,
    required IncidentStatus target,
  }) async {
    if (busyId.value.isNotEmpty) return;
    try {
      busyId.value = incident.id;
      final ok = await _repo.changeStatus(
        id: incident.id,
        status: DisciplineEnums.statusValue(target),
      );
      if (ok) {
        Utils.snackBar(TranslationKeys.statusUpdated.tr, false);
        await loadAdminIncidents(force: true);
      } else {
        Utils.snackBar(TranslationKeys.failedToSaveDecision.tr, true);
      }
    } finally {
      busyId.value = '';
    }
  }

  /// [valid] true confirms the incident (counts toward a warning), false
  /// rejects it.
  Future<bool> review({
    required DisciplineIncident incident,
    required bool valid,
    required String comments,
  }) async {
    if (comments.trim().isEmpty) {
      Utils.snackBar(TranslationKeys.reviewCommentsRequired.tr, true);
      return false;
    }
    try {
      busyId.value = incident.id;
      final ok = await _repo.review(
        id: incident.id,
        disposition: valid ? 'Valid' : 'Invalid',
        comments: comments.trim(),
      );
      if (ok) {
        Utils.snackBar(TranslationKeys.decisionSaved.tr, false);
        await loadAdminIncidents(force: true);
      } else {
        Utils.snackBar(TranslationKeys.failedToSaveDecision.tr, true);
      }
      return ok;
    } finally {
      busyId.value = '';
    }
  }

  Future<void> deleteIncident(String id) async {
    final ok = await _repo.deleteIncident(id);
    if (ok) {
      allIncidents.removeWhere((i) => i.id == id);
      Utils.snackBar(TranslationKeys.requestDeleted.tr, false);
    } else {
      Utils.snackBar(TranslationKeys.failedToDeleteReport.tr, true);
    }
  }

  /// Checked before issuing a letter so HR sees the threshold up front.
  Future<void> checkEligibility(String employeeId) async {
    try {
      isCheckingEligibility.value = true;
      eligibility.value = null;
      final body = await _repo.eligibility(employeeId);
      if (body != null) {
        // The service returns the fields at the top level, not under `data`.
        final data = body['data'] is Map ? body['data'] : body;
        eligibility.value = WarningEligibility.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } finally {
      isCheckingEligibility.value = false;
    }
  }

  Future<bool> issueWarning({
    required DisciplineIncident incident,
    required String warningType,
    required DateTime letterDate,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      Utils.snackBar(TranslationKeys.letterContentRequired.tr, true);
      return false;
    }
    try {
      isSubmitting.value = true;
      final prefs = await SharedPreferences.getInstance();
      final body = await _repo.createWarning({
        'incident_id': incident.id,
        'employee_id': incident.employeeId,
        'employee_name': incident.employeeName,
        'letter_date': letterDate.toUtc().toIso8601String(),
        'warning_type': warningType,
        'content': content.trim(),
        'issued_by': prefs.getString('user_id') ?? '',
      });
      if (body == null) {
        Utils.snackBar(TranslationKeys.failedToIssueWarning.tr, true);
        return false;
      }
      await loadAdminWarnings(force: true);
      Utils.snackBar(TranslationKeys.warningIssued.tr, false);
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteWarning(String id) async {
    final ok = await _repo.deleteWarning(id);
    if (ok) {
      allWarnings.removeWhere((w) => w.id == id);
      Utils.snackBar(TranslationKeys.requestDeleted.tr, false);
    } else {
      Utils.snackBar(TranslationKeys.failedToDeleteReport.tr, true);
    }
  }
}
