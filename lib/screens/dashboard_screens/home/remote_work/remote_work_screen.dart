import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/remote_work_controller.dart';
import 'package:supergithr/models/remote_work_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/remote_work_widgets.dart';

class RemoteWorkScreen extends StatefulWidget {
  const RemoteWorkScreen({super.key});

  @override
  State<RemoteWorkScreen> createState() => _RemoteWorkScreenState();
}

class _RemoteWorkScreenState extends State<RemoteWorkScreen> {
  final RemoteWorkController _c = Get.put(RemoteWorkController());

  /// Ids of history cards whose approval trail is expanded.
  final RxSet<String> _expanded = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    // Another device may have ended the session — always re-check on open.
    _c.loadMySessions(force: true);
  }

  Future<void> _confirmClockOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: kText(
          text: TranslationKeys.clockOutConfirm.tr,
          fSize: 15.0,
          fWeight: FontWeight.w600,
          tColor: Colors.black87,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: kText(
              text: TranslationKeys.cancel.tr,
              fSize: 13.5,
              tColor: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffE05260),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: kText(
              text: TranslationKeys.clockOut.tr,
              fSize: 13.5,
              fWeight: FontWeight.w600,
              tColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _c.clockOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.remoteWork.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          return RefreshIndicator(
            onRefresh: () => _c.loadMySessions(force: true),
            color: kPrimaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                _sessionCard(),
                const SizedBox(height: 16),
                _statsRow(),
                const SizedBox(height: 22),
                kText(
                  text: TranslationKeys.sessionHistory.tr,
                  fSize: 15.0,
                  fWeight: FontWeight.w700,
                  tColor: Colors.black87,
                ),
                const SizedBox(height: 12),
                if (_c.isLoading.value && _c.sessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  )
                else if (_c.sessions.where((s) => !s.isActive).isEmpty)
                  _emptyHistory()
                else
                  ..._c.sessions.where((s) => !s.isActive).map(_historyCard),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// The hero: a live stopwatch while clocked in, a clock-in prompt otherwise.
  Widget _sessionCard() {
    final active = _c.activeSession;
    final isRunning = active != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors:
              isRunning
                  ? [const Color(0xff17A673), const Color(0xff2E9E5B)]
                  : [kPrimaryColor, const Color(0xff00A3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isRunning ? const Color(0xff2E9E5B) : kPrimaryColor)
                .withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? const Color(0xff9BFFCB) : Colors.white70,
                ),
              ),
              const SizedBox(width: 9),
              kText(
                text:
                    isRunning
                        ? "${TranslationKeys.activeRemoteSession.tr} · ${TranslationKeys.inProgress.tr}"
                        : TranslationKeys.remoteWork.tr,
                fSize: 12.5,
                fWeight: FontWeight.w600,
                tColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
          const SizedBox(height: 18),
          kText(
            text:
                isRunning
                    ? RemoteWorkController.formatStopwatch(_c.elapsed.value)
                    : DateFormat('hh:mm a').format(DateTime.now()),
            fSize: isRunning ? 38.0 : 30.0,
            fWeight: FontWeight.w700,
            tColor: Colors.white,
          ),
          if (isRunning && active.clockInTime != null) ...[
            const SizedBox(height: 6),
            kText(
              text:
                  "${TranslationKeys.clockedInAtTime.tr} "
                  "${DateFormat('hh:mm a · d MMM').format(active.clockInTime!)}",
              fSize: 12.0,
              tColor: Colors.white.withValues(alpha: 0.85),
            ),
          ],
          if (isRunning && active.clockInLocation != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  size: 12,
                  color: Colors.white70,
                ),
                const SizedBox(width: 5),
                kText(
                  text: active.clockInLocation!.short,
                  fSize: 11.0,
                  tColor: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  _c.isClocking.value
                      ? null
                      : (isRunning ? _confirmClockOut : _c.clockIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white70,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  _c.isClocking.value
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              isRunning
                                  ? const Color(0xffE05260)
                                  : kPrimaryColor,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRunning
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline_rounded,
                            size: 20,
                            color:
                                isRunning
                                    ? const Color(0xffE05260)
                                    : kPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          kText(
                            text:
                                isRunning
                                    ? TranslationKeys.clockOut.tr
                                    : TranslationKeys.clockIn.tr,
                            fSize: 15.0,
                            fWeight: FontWeight.w700,
                            tColor:
                                isRunning
                                    ? const Color(0xffE05260)
                                    : kPrimaryColor,
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    Widget tile(String label, String value, IconData icon, Color color) =>
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(height: 10),
                kText(
                  text: value,
                  fSize: 17.0,
                  fWeight: FontWeight.w700,
                  tColor: Colors.black87,
                ),
                const SizedBox(height: 2),
                kText(
                  text: label,
                  fSize: 10.5,
                  tColor: Colors.grey.shade600,
                  maxLines: 1,
                  textoverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile(
          TranslationKeys.totalSessions.tr,
          '${_c.totalSessions}',
          Icons.event_note_rounded,
          kPrimaryColor,
        ),
        tile(
          TranslationKeys.pendingApprovals.tr,
          '${_c.pendingCount}',
          Icons.hourglass_top_rounded,
          const Color(0xffE08B00),
        ),
        tile(
          TranslationKeys.approvedSessions.tr,
          '${_c.approvedCount}',
          Icons.check_circle_rounded,
          const Color(0xff2E9E5B),
        ),
        tile(
          TranslationKeys.totalHours.tr,
          _c.totalHours,
          Icons.timer_outlined,
          const Color(0xff7A3FD6),
        ),
      ],
    );
  }

  Widget _emptyHistory() => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      children: [
        Icon(Icons.laptop_mac_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        kText(
          text: TranslationKeys.noRemoteSessions.tr,
          fSize: 13.5,
          tColor: Colors.grey.shade500,
        ),
      ],
    ),
  );

  Widget _historyCard(RemoteWorkSession session) {
    final start = session.clockInTime;
    final end = session.clockOutTime;
    final isOpen = _expanded.contains(session.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: kText(
                  text:
                      start == null
                          ? '—'
                          : DateFormat('EEEE, d MMM yyyy').format(start),
                  fSize: 13.5,
                  fWeight: FontWeight.w700,
                  tColor: Colors.black87,
                ),
              ),
              RemoteStatusBadge(status: session.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _timeChip(
                Icons.login_rounded,
                start == null ? '—' : DateFormat('hh:mm a').format(start),
              ),
              const SizedBox(width: 8),
              _timeChip(
                Icons.logout_rounded,
                end == null ? '—' : DateFormat('hh:mm a').format(end),
              ),
              const Spacer(),
              if (session.duration != null)
                kText(
                  text: RemoteWorkController.formatDuration(session.duration!),
                  fSize: 13.0,
                  fWeight: FontWeight.w700,
                  tColor: kPrimaryColor,
                ),
            ],
          ),
          if (session.autoClockedOut) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                kText(
                  text: TranslationKeys.autoClockedOut.tr,
                  fSize: 11.0,
                  tColor: Colors.grey.shade500,
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Container(height: 1, color: Colors.grey.shade100),
          InkWell(
            onTap: () {
              if (isOpen) {
                _expanded.remove(session.id);
              } else {
                _expanded.add(session.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  kText(
                    text: TranslationKeys.approvalTrail.tr,
                    fSize: 12.0,
                    fWeight: FontWeight.w600,
                    tColor: kPrimaryColor,
                  ),
                  const Spacer(),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) _trail(session),
        ],
      ),
    );
  }

  Widget _timeChip(IconData icon, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kMainBackgroundColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        kText(
          text: value,
          fSize: 11.5,
          fWeight: FontWeight.w600,
          tColor: Colors.black87,
        ),
      ],
    ),
  );

  Widget _trail(RemoteWorkSession session) {
    final df = DateFormat('d MMM · hh:mm a');
    final rejected = session.status == RemoteStatus.rejected;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: [
          ApprovalTrailStep(
            icon: Icons.person_outline_rounded,
            title: TranslationKeys.employeeCheckIn.tr,
            subtitle: [
              if (session.clockInTime != null) df.format(session.clockInTime!),
              if (session.clockInLocation != null)
                session.clockInLocation!.short,
            ].join('  ·  '),
            done: true,
          ),
          ApprovalTrailStep(
            icon: Icons.supervisor_account_outlined,
            title: TranslationKeys.teamLeadReview.tr,
            subtitle:
                session.teamLeadApprovedAt != null
                    ? [
                      if (session.teamLeadName.isNotEmpty) session.teamLeadName,
                      df.format(session.teamLeadApprovedAt!),
                    ].join('  ·  ')
                    : (rejected
                        ? TranslationKeys.statusRejected.tr
                        : TranslationKeys.awaitingReview.tr),
            done: session.teamLeadApprovedAt != null,
          ),
          ApprovalTrailStep(
            icon: Icons.verified_user_outlined,
            title: TranslationKeys.adminReview.tr,
            subtitle:
                session.adminApprovedAt != null
                    ? [
                      df.format(session.adminApprovedAt!),
                      if (session.attendanceLogId.isNotEmpty)
                        "${TranslationKeys.attendanceLog.tr}: ${session.attendanceLogId}",
                    ].join('  ·  ')
                    : (rejected
                        ? TranslationKeys.statusRejected.tr
                        : TranslationKeys.awaitingReview.tr),
            done: session.adminApprovedAt != null,
            isLast: true,
          ),
          if (session.remarks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kMainBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: kText(
                text: session.remarks,
                fSize: 12.0,
                tColor: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
