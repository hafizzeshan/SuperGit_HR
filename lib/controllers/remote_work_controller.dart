import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/models/remote_work_model.dart';
import 'package:supergithr/network/repository/remote_work_repo/remote_work_repo.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/utils.dart';

class RemoteWorkController extends GetxController {
  final RemoteWorkRepository _repo = RemoteWorkRepository();

  // ── employee state ──────────────────────────────────────────────────────
  final sessions = <RemoteWorkSession>[].obs;
  final isLoading = false.obs;
  final hasLoadedOnce = false.obs;
  final isClocking = false.obs;

  /// Elapsed time of the running session, refreshed every second.
  final elapsed = Duration.zero.obs;
  Timer? _ticker;

  RemoteWorkSession? get activeSession =>
      sessions.firstWhereOrNull((s) => s.isActive);

  bool get isClockedIn => activeSession != null;

  // ── approvals state (shared by team lead and admin) ─────────────────────
  final approvals = <RemoteWorkSession>[].obs;
  final isLoadingApprovals = false.obs;
  final approvalFilter = 'ALL'.obs;
  final decidingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMySessions();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  // ── stats for the header cards ──────────────────────────────────────────

  int get totalSessions => sessions.length;

  int get pendingCount =>
      sessions.where((s) => s.isPending && !s.isActive).length;

  int get approvedCount =>
      sessions.where((s) => s.status == RemoteStatus.approved).length;

  /// Hours counted from approved sessions only, as the web app does.
  String get totalHours {
    var minutes = 0;
    for (final s in sessions) {
      if (s.status != RemoteStatus.approved) continue;
      minutes += s.duration?.inMinutes ?? 0;
    }
    return (minutes / 60).toStringAsFixed(1);
  }

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  static String formatStopwatch(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}'
        ':${two(d.inSeconds.remainder(60))}';
  }

  // ── history ─────────────────────────────────────────────────────────────

  /// Reads once per session; [force] re-reads (pull-to-refresh, or after a
  /// clock in/out so the server stays the source of truth).
  Future<void> loadMySessions({bool force = false}) async {
    if (hasLoadedOnce.value && !force) {
      _syncTicker();
      return;
    }
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final body = await _repo.mySessions();
      final raw = body?['data'];
      sessions.assignAll(
        raw is List
            ? raw
                .whereType<Map>()
                .map(
                  (e) =>
                      RemoteWorkSession.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
            : <RemoteWorkSession>[],
      );
    } finally {
      isLoading.value = false;
      hasLoadedOnce.value = true;
      _syncTicker();
    }
  }

  /// Keeps the stopwatch in step with whatever the server says. Elapsed time
  /// is derived from `clock_in_time`, so killing the app doesn't lose it.
  void _syncTicker() {
    final active = activeSession;
    _ticker?.cancel();
    if (active?.clockInTime == null) {
      elapsed.value = Duration.zero;
      return;
    }
    void tick() =>
        elapsed.value = DateTime.now().difference(active!.clockInTime!);
    tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  // ── clock in / out ──────────────────────────────────────────────────────

  /// Returns coordinates, or null after telling the user what is missing.
  Future<Position?> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Utils.snackBar(TranslationKeys.locationServicesAreOff.tr, true);
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Utils.snackBar(TranslationKeys.locationPermissionDenied.tr, true);
      return null;
    }

    try {
      // High accuracy, but time-boxed so a weak signal can't hang the button.
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      Utils.snackBar(TranslationKeys.unableToFetchLocation.tr, true);
      return null;
    }
  }

  Future<bool> clockIn() => _clock(isClockIn: true);

  Future<bool> clockOut() => _clock(isClockIn: false);

  Future<bool> _clock({required bool isClockIn}) async {
    if (isClocking.value) return false;
    try {
      isClocking.value = true;
      final position = await _currentPosition();
      if (position == null) return false;

      final body =
          isClockIn
              ? await _repo.clockIn(
                latitude: position.latitude,
                longitude: position.longitude,
              )
              : await _repo.clockOut(
                latitude: position.latitude,
                longitude: position.longitude,
              );

      if (body == null) {
        Utils.snackBar(
          isClockIn
              ? TranslationKeys.remoteClockInFailed.tr
              : TranslationKeys.remoteClockOutFailed.tr,
          true,
        );
        return false;
      }

      await loadMySessions(force: true);
      Utils.snackBar(
        isClockIn
            ? TranslationKeys.remoteClockedIn.tr
            : TranslationKeys.remoteClockedOut.tr,
        false,
      );
      return true;
    } finally {
      isClocking.value = false;
    }
  }

  // ── approvals (team lead / admin) ───────────────────────────────────────

  Future<void> loadApprovals(ApprovalMode mode, {bool force = false}) async {
    if (isLoadingApprovals.value) return;
    try {
      isLoadingApprovals.value = true;
      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd');
      final body = await _repo.pendingApprovals(
        isAdmin: mode == ApprovalMode.admin,
        // Defaults to the current month, as the web screen does.
        fromDate: formatter.format(DateTime(now.year, now.month, 1)),
        toDate: formatter.format(DateTime(now.year, now.month + 1, 0)),
        status: approvalFilter.value,
      );
      final raw = body?['data'];
      approvals.assignAll(
        raw is List
            ? raw
                .whereType<Map>()
                .map(
                  (e) =>
                      RemoteWorkSession.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
            : <RemoteWorkSession>[],
      );
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  void setApprovalFilter(ApprovalMode mode, String filter) {
    if (approvalFilter.value == filter) return;
    approvalFilter.value = filter;
    loadApprovals(mode, force: true);
  }

  Future<void> decide({
    required ApprovalMode mode,
    required RemoteWorkSession session,
    required bool approved,
    String remarks = '',
  }) async {
    if (decidingId.value.isNotEmpty) return;
    try {
      decidingId.value = session.id;
      final ok = await _repo.decide(
        id: session.id,
        isAdmin: mode == ApprovalMode.admin,
        approved: approved,
        remarks: remarks,
      );
      if (ok) {
        Utils.snackBar(TranslationKeys.decisionSaved.tr, false);
        await loadApprovals(mode, force: true);
      } else {
        Utils.snackBar(TranslationKeys.failedToSaveDecision.tr, true);
      }
    } finally {
      decidingId.value = '';
    }
  }
}
