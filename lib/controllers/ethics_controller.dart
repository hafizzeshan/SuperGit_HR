import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:supergithr/models/ethics_report_model.dart';
import 'package:supergithr/network/repository/ethics_repo/ethics_repo.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/utils.dart';

class EthicsController extends GetxController {
  final EthicsRepository _repo = EthicsRepository();

  /// The service rejects anything larger, so stop it on the device.
  static const int maxFileBytes = 10 * 1024 * 1024;
  static const int _pageSize = 10;

  final reports = <EthicsReport>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSubmitting = false.obs;

  /// Shimmer is tied to this, so it only shows before the first result.
  final hasLoadedOnce = false.obs;

  final totalRecords = 0.obs;
  int _page = 1;
  bool _hasMore = true;

  /// Files chosen for the report currently being written.
  final pickedFiles = <PlatformFile>[].obs;

  /// Detail screen state.
  final selectedReport = Rxn<EthicsReport>();
  final isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  /// Reads the first page once per session; [force] re-reads (pull-to-refresh).
  Future<void> fetchReports({bool force = false}) async {
    if (hasLoadedOnce.value && !force) return;
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      _page = 1;
      final body = await _repo.myReports(page: _page, pageSize: _pageSize);
      _applyPage(body, replace: true);
    } finally {
      isLoading.value = false;
      hasLoadedOnce.value = true;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      final body = await _repo.myReports(page: _page + 1, pageSize: _pageSize);
      if (body != null) _page += 1;
      _applyPage(body, replace: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _applyPage(Map<String, dynamic>? body, {required bool replace}) {
    if (body == null) {
      if (replace) reports.clear();
      _hasMore = false;
      return;
    }
    final raw = body['data'];
    final items =
        raw is List
            ? raw
                .whereType<Map>()
                .map((e) => EthicsReport.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <EthicsReport>[];

    if (replace) {
      reports.assignAll(items);
    } else {
      reports.addAll(items);
    }

    totalRecords.value =
        int.tryParse('${body['total'] ?? reports.length}') ?? reports.length;
    final totalPages = int.tryParse('${body['total_pages'] ?? 1}') ?? 1;
    _hasMore = _page < totalPages;
  }

  Future<void> loadDetails(String id) async {
    try {
      isLoadingDetail.value = true;
      final body = await _repo.details(id);
      final data = body?['data'];
      if (data is Map) {
        selectedReport.value = EthicsReport.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // ── attachments being attached to a new/edited report ───────────────────

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null) return;

      for (final file in result.files) {
        if (file.path == null || file.path!.isEmpty) continue;
        if (file.size > maxFileBytes) {
          Utils.snackBar(
            "${file.name}: ${TranslationKeys.fileTooLargeMax10Mb.tr}",
            true,
          );
          continue;
        }
        if (pickedFiles.any((f) => f.path == file.path)) continue;
        pickedFiles.add(file);
      }
    } catch (e) {
      Utils.snackBar(TranslationKeys.failedToPickImage.tr, true);
    }
  }

  void removePickedFile(PlatformFile file) => pickedFiles.remove(file);

  void clearDraft() => pickedFiles.clear();

  // ── create / edit / delete ──────────────────────────────────────────────

  /// Validates the form the same way the API does, so mistakes surface before
  /// a round trip. Returns null when everything is fine.
  String? validate({required String category, required String description}) {
    if (category.isEmpty) return TranslationKeys.pleaseSelectCategory.tr;
    if (description.trim().length < 20) {
      return TranslationKeys.descriptionMin20Chars.tr;
    }
    return null;
  }

  Map<String, dynamic> _payload({
    required String category,
    required EthicsSeverity severity,
    required String description,
    required bool immediateDanger,
    DateTime? incidentDate,
    String incidentLocation = '',
    String peopleInvolved = '',
  }) {
    return {
      'category': category,
      'severity': EthicsEnums.severityKey(severity),
      'description': description.trim(),
      'immediate_danger': immediateDanger,
      if (incidentDate != null)
        'incident_date': incidentDate.toUtc().toIso8601String(),
      if (incidentLocation.trim().isNotEmpty)
        'incident_location': incidentLocation.trim(),
      if (peopleInvolved.trim().isNotEmpty)
        'people_involved': peopleInvolved.trim(),
    };
  }

  /// Creates the report, then uploads each attachment against the new id.
  Future<bool> submit({
    required String category,
    required EthicsSeverity severity,
    required String description,
    required bool immediateDanger,
    DateTime? incidentDate,
    String incidentLocation = '',
    String peopleInvolved = '',
  }) async {
    final error = validate(category: category, description: description);
    if (error != null) {
      Utils.snackBar(error, true);
      return false;
    }

    try {
      isSubmitting.value = true;
      final body = await _repo.create(
        _payload(
          category: category,
          severity: severity,
          description: description,
          immediateDanger: immediateDanger,
          incidentDate: incidentDate,
          incidentLocation: incidentLocation,
          peopleInvolved: peopleInvolved,
        ),
      );

      final id = '${(body?['data'] as Map?)?['id'] ?? ''}';
      if (id.isEmpty) {
        Utils.snackBar(TranslationKeys.failedToSubmitReport.tr, true);
        return false;
      }

      await _uploadPickedFiles(id);
      clearDraft();
      await fetchReports(force: true);
      Utils.snackBar(TranslationKeys.reportSubmittedSuccessfully.tr, false);
      return true;
    } catch (e) {
      Utils.snackBar(TranslationKeys.failedToSubmitReport.tr, true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateReport({
    required String id,
    required String category,
    required EthicsSeverity severity,
    required String description,
    required bool immediateDanger,
    DateTime? incidentDate,
    String incidentLocation = '',
    String peopleInvolved = '',
  }) async {
    final error = validate(category: category, description: description);
    if (error != null) {
      Utils.snackBar(error, true);
      return false;
    }

    try {
      isSubmitting.value = true;
      final body = await _repo.update(
        id,
        _payload(
          category: category,
          severity: severity,
          description: description,
          immediateDanger: immediateDanger,
          incidentDate: incidentDate,
          incidentLocation: incidentLocation,
          peopleInvolved: peopleInvolved,
        ),
      );
      if (body == null) {
        Utils.snackBar(TranslationKeys.failedToUpdateReport.tr, true);
        return false;
      }

      await _uploadPickedFiles(id);
      clearDraft();
      await loadDetails(id);
      await fetchReports(force: true);
      Utils.snackBar(TranslationKeys.reportUpdatedSuccessfully.tr, false);
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _uploadPickedFiles(String reportId) async {
    for (final file in List<PlatformFile>.from(pickedFiles)) {
      if (file.path == null) continue;
      final uploaded = await _repo.uploadAttachment(
        reportId: reportId,
        filePath: file.path!,
        fileName: file.name,
      );
      if (uploaded == null) {
        Utils.snackBar(
          "${file.name}: ${TranslationKeys.attachmentUploadFailed.tr}",
          true,
        );
      }
    }
  }

  Future<bool> deleteReport(String id) async {
    final ok = await _repo.delete(id);
    if (ok) {
      reports.removeWhere((r) => r.id == id);
      totalRecords.value = (totalRecords.value - 1).clamp(0, 1 << 30);
      Utils.snackBar(TranslationKeys.reportDeletedSuccessfully.tr, false);
    } else {
      Utils.snackBar(TranslationKeys.failedToDeleteReport.tr, true);
    }
    return ok;
  }

  Future<void> deleteAttachment({
    required String reportId,
    required String attachmentId,
  }) async {
    final ok = await _repo.deleteAttachment(
      reportId: reportId,
      attachmentId: attachmentId,
    );
    if (ok) {
      await loadDetails(reportId);
    } else {
      Utils.snackBar(TranslationKeys.failedToDeleteAttachment.tr, true);
    }
  }
}
