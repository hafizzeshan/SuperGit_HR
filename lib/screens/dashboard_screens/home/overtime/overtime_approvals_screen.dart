import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/overtime_controller.dart';
import 'package:supergithr/models/overtime_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/overtime/overtime_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';

/// Manager and admin queues in one screen — the card layout is identical and
/// only the endpoints and the "manager already approved" row differ.
class OvertimeApprovalsScreen extends StatefulWidget {
  final bool isAdmin;

  const OvertimeApprovalsScreen({super.key, required this.isAdmin});

  @override
  State<OvertimeApprovalsScreen> createState() =>
      _OvertimeApprovalsScreenState();
}

class _OvertimeApprovalsScreenState extends State<OvertimeApprovalsScreen> {
  final OvertimeController _c = Get.find<OvertimeController>();

  static const List<OvertimeStage?> _filters = [
    null,
    OvertimeStage.pendingManager,
    OvertimeStage.pendingAdmin,
    OvertimeStage.approved,
    OvertimeStage.rejected,
  ];

  @override
  void initState() {
    super.initState();
    // Admins land on the stage they act on; managers on theirs.
    _c.approvalFilter.value =
        widget.isAdmin
            ? OvertimeStage.pendingAdmin
            : OvertimeStage.pendingManager;
    _c.loadApprovals(isAdmin: widget.isAdmin, force: true);
  }

  String _filterLabel(OvertimeStage? stage) =>
      stage == null
          ? TranslationKeys.filterAll.tr
          : _OvertimeApprovalsScreenState.stageLabel(stage);

  static String stageLabel(OvertimeStage stage) =>
      _OvertimeScreenLabels.label(stage);

  Future<void> _decide(OvertimeDatum request, bool approve) async {
    if (approve) {
      await _c.decide(isAdmin: widget.isAdmin, request: request, approve: true);
      return;
    }

    final remarks = TextEditingController();
    final confirmed = await Get.bottomSheet<bool>(
      Container(
        padding: context.sheetPadding(),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            kText(
              text: TranslationKeys.rejectionReason.tr,
              fSize: 16.0,
              fWeight: FontWeight.w700,
              tColor: Colors.black87,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: remarks,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: TranslationKeys.reasonForRejection.tr,
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: kMainBackgroundColor,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: kText(
                  text: TranslationKeys.reject.tr,
                  fSize: 15.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );

    if (confirmed == true) {
      await _c.decide(
        isAdmin: widget.isAdmin,
        request: request,
        approve: false,
        remarks: remarks.text,
        reason: remarks.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.overtimeApprovals.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Column(
          children: [
            _filterBar(),
            Expanded(
              child: Obx(() {
                if (_c.isLoadingApprovals.value && _c.approvals.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }
                return RefreshIndicator(
                  onRefresh:
                      () => _c.loadApprovals(
                        isAdmin: widget.isAdmin,
                        force: true,
                      ),
                  color: kPrimaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      28,
                    ).atLeastBottom(context.gestureInset + 8),
                    children: [
                      if (_c.approvals.isEmpty)
                        _emptyState()
                      else
                        ..._c.approvals.map(_card),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterBar() => Obx(() {
    // Read the observable here, in the Obx builder itself — reading it only
    // inside itemBuilder (which runs lazily) leaves Obx with nothing to watch.
    final active = _c.approvalFilter.value;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ).atLeastBottom(context.gestureInset + 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final stage = _filters[index];
          final selected = active == stage;
          return GestureDetector(
            onTap:
                () =>
                    _c.setApprovalFilter(isAdmin: widget.isAdmin, stage: stage),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? kPrimaryColor : Colors.grey.shade200,
                ),
              ),
              child: kText(
                text: _filterLabel(stage),
                fSize: 12.5,
                fWeight: selected ? FontWeight.w600 : FontWeight.w500,
                tColor: selected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  });

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.only(top: 70),
    child: Column(
      children: [
        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        kText(
          text: TranslationKeys.noPendingApprovals.tr,
          fSize: 13.5,
          tColor: Colors.grey.shade500,
        ),
      ],
    ),
  );

  Widget _card(OvertimeDatum request) {
    final stage = request.stage;
    // A manager only acts on their own stage; an admin only on theirs.
    final canDecide =
        widget.isAdmin
            ? stage == OvertimeStage.pendingAdmin ||
                stage == OvertimeStage.pendingManager
            : stage == OvertimeStage.pendingManager;

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
              CircleAvatar(
                radius: 19,
                backgroundColor: kPrimaryColor.withValues(alpha: 0.10),
                child: kText(
                  text:
                      request.employeeName.isNotEmpty
                          ? request.employeeName[0].toUpperCase()
                          : '?',
                  fSize: 15.0,
                  fWeight: FontWeight.w700,
                  tColor: kPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kText(
                      text: request.employeeName,
                      fSize: 13.5,
                      fWeight: FontWeight.w700,
                      tColor: Colors.black87,
                      maxLines: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    kText(
                      text: [
                        if (request.employeeCode.isNotEmpty)
                          request.employeeCode,
                        if (request.date != null)
                          DateFormat('EEE, d MMM yyyy').format(request.date!),
                      ].join('  ·  '),
                      fSize: 11.0,
                      tColor: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
              _badge(stage),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kMainBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _stat(Icons.timer_outlined, request.durationLabel),
                    if (request.overtimeRate > 0)
                      _stat(Icons.percent_rounded, '${request.overtimeRate}x'),
                    if (request.overtimeAmount > 0)
                      _stat(
                        Icons.payments_outlined,
                        '${request.overtimeAmount}',
                      ),
                  ],
                ),
                if (request.reason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: kText(
                      text: request.reason,
                      fSize: 12.0,
                      tColor: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Admins can see the manager already signed off before deciding.
          if (widget.isAdmin && request.managerApprovedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xff10B981),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: kText(
                    text:
                        "${TranslationKeys.managerApproved.tr}: "
                        "${request.managerName.isEmpty ? '' : '${request.managerName} · '}"
                        "${DateFormat('d MMM · hh:mm a').format(request.managerApprovedAt!)}",
                    fSize: 11.0,
                    tColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
          if (canDecide) ...[
            const SizedBox(height: 14),
            Obx(() {
              final busy = _c.decidingId.value == request.id;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : () => _decide(request, false),
                      icon: const Icon(Icons.close_rounded, size: 17),
                      label: kText(
                        text: TranslationKeys.reject.tr,
                        fSize: 13.0,
                        fWeight: FontWeight.w600,
                        tColor: const Color(0xffEF4444),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffEF4444),
                        side: const BorderSide(color: Color(0xffEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : () => _decide(request, true),
                      icon:
                          busy
                              ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.check_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                      label: kText(
                        text: TranslationKeys.approve.tr,
                        fSize: 13.0,
                        fWeight: FontWeight.w600,
                        tColor: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff10B981),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _badge(OvertimeStage stage) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: stage.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stage.icon, size: 11, color: stage.color),
        const SizedBox(width: 4),
        kText(
          text: _OvertimeScreenLabels.label(stage),
          fSize: 10.5,
          fWeight: FontWeight.w600,
          tColor: stage.color,
        ),
      ],
    ),
  );

  Widget _stat(IconData icon, String value) => Expanded(
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Flexible(
          child: kText(
            text: value,
            fSize: 11.5,
            fWeight: FontWeight.w600,
            tColor: Colors.black87,
            maxLines: 1,
            textoverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// Single source for the stage labels shared with [OvertimeScreen].
class _OvertimeScreenLabels {
  static String label(OvertimeStage stage) =>
      OvertimeScreenState.stageLabel(stage);
}
