import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/remote_work_controller.dart';
import 'package:supergithr/models/remote_work_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/remote_work_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// One screen for both approval tiers — the layouts are identical and only
/// the endpoints and the extra "team lead already approved" row differ.
class RemoteApprovalsScreen extends StatefulWidget {
  final ApprovalMode mode;

  const RemoteApprovalsScreen({super.key, required this.mode});

  @override
  State<RemoteApprovalsScreen> createState() => _RemoteApprovalsScreenState();
}

class _RemoteApprovalsScreenState extends State<RemoteApprovalsScreen> {
  final RemoteWorkController _c = Get.put(RemoteWorkController());

  static const _filters = ['ALL', 'PENDING', 'APPROVED', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _c.loadApprovals(widget.mode, force: true);
  }

  String _filterLabel(String key) => switch (key) {
    'PENDING' => TranslationKeys.filterPending.tr,
    'APPROVED' => TranslationKeys.filterApproved.tr,
    'REJECTED' => TranslationKeys.filterRejected.tr,
    _ => TranslationKeys.filterAll.tr,
  };

  Future<void> _openMaps(RemoteLocation location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${location.latitude},${location.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Approving is one tap; rejecting asks for remarks first, since a rejection
  /// without a reason is not much use to the employee.
  Future<void> _decide(RemoteWorkSession session, bool approved) async {
    if (approved) {
      await _c.decide(mode: widget.mode, session: session, approved: true);
      return;
    }

    final controller = TextEditingController();
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
              text: TranslationKeys.reject.tr,
              fSize: 16.0,
              fWeight: FontWeight.w700,
              tColor: Colors.black87,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: TranslationKeys.remarksOptional.tr,
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
                  backgroundColor: const Color(0xffE05260),
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
        mode: widget.mode,
        session: session,
        approved: false,
        remarks: controller.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.remoteApprovals.tr,
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
                  onRefresh: () => _c.loadApprovals(widget.mode, force: true),
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
                        ..._c.approvals.map(_approvalCard),
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

  Widget _filterBar() {
    return Obx(() {
      // Same reason as above: Obx must see the observable during its build.
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
            final key = _filters[index];
            final selected = active == key;
            return GestureDetector(
              onTap: () => _c.setApprovalFilter(widget.mode, key),
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
                  text: _filterLabel(key),
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
  }

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

  Widget _approvalCard(RemoteWorkSession session) {
    final start = session.clockInTime;
    final end = session.clockOutTime;
    final initial =
        session.employeeName.isNotEmpty
            ? session.employeeName[0].toUpperCase()
            : '?';
    final canDecide = session.isPending;

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
                  text: initial,
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
                      text: session.employeeName,
                      fSize: 13.5,
                      fWeight: FontWeight.w700,
                      tColor: Colors.black87,
                      maxLines: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    kText(
                      text:
                          start == null
                              ? '—'
                              : DateFormat('EEE, d MMM yyyy').format(start),
                      fSize: 11.0,
                      tColor: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
              RemoteStatusBadge(status: session.status),
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
                    _stat(
                      Icons.login_rounded,
                      start == null ? '—' : DateFormat('hh:mm a').format(start),
                    ),
                    _stat(
                      Icons.logout_rounded,
                      end == null ? '—' : DateFormat('hh:mm a').format(end),
                    ),
                    _stat(
                      Icons.timer_outlined,
                      session.duration == null
                          ? '—'
                          : RemoteWorkController.formatDuration(
                            session.duration!,
                          ),
                    ),
                  ],
                ),
                if (session.clockInLocation != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _openMaps(session.clockInLocation!),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: kText(
                            text: session.clockInLocation!.short,
                            fSize: 11.0,
                            tColor: Colors.grey.shade700,
                          ),
                        ),
                        kText(
                          text: TranslationKeys.openInMaps.tr,
                          fSize: 11.0,
                          fWeight: FontWeight.w600,
                          tColor: kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Admins get to see that the team lead already signed off.
          if (widget.mode == ApprovalMode.admin &&
              session.teamLeadApprovedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xff2E9E5B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: kText(
                    text:
                        "${TranslationKeys.teamLeadReview.tr}: "
                        "${session.teamLeadName.isEmpty ? '' : '${session.teamLeadName} · '}"
                        "${DateFormat('d MMM · hh:mm a').format(session.teamLeadApprovedAt!)}",
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
              final busy = _c.decidingId.value == session.id;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : () => _decide(session, false),
                      icon: const Icon(Icons.close_rounded, size: 17),
                      label: kText(
                        text: TranslationKeys.reject.tr,
                        fSize: 13.0,
                        fWeight: FontWeight.w600,
                        tColor: const Color(0xffE05260),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffE05260),
                        side: const BorderSide(color: Color(0xffE05260)),
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
                      onPressed: busy ? null : () => _decide(session, true),
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
                        backgroundColor: const Color(0xff2E9E5B),
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
