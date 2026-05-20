import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/controllers/team_leave_controller.dart';
import 'package:supergithr/models/team_leave_request_model.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class TeamLeaveRequestsScreen extends StatefulWidget {
  const TeamLeaveRequestsScreen({super.key});

  @override
  State<TeamLeaveRequestsScreen> createState() =>
      _TeamLeaveRequestsScreenState();
}

class _TeamLeaveRequestsScreenState extends State<TeamLeaveRequestsScreen> {
  final TeamLeaveController c = Get.find<TeamLeaveController>();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Page-level guard: bounce unauthorized users out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!c.canReview) {
        Get.back();
        return;
      }
      c.fetchRequests();
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        c.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: "Team Leave Requests"),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () => c.fetchRequests(),
          child: Obx(() {
            if (c.isLoading.value && c.requests.isEmpty) {
              return _shimmer();
            }
            if (c.requests.isEmpty) return _empty();
            return ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: c.requests.length + 1,
              itemBuilder: (_, i) {
                if (i == c.requests.length) return _footer();
                final r = c.requests[i];
                return _RequestCard(
                  request: r,
                  onApprove: () => _confirmAction(r, approve: true),
                  onReject: () => _confirmAction(r, approve: false),
                  onView: () => _showDetails(r),
                ).animate().fadeIn(duration: 300.ms, delay: (i * 40).ms);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _footer() {
    return Obx(() {
      if (c.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
        );
      }
      if (!c.hasMore && c.requests.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "No more requests",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        );
      }
      return const SizedBox(height: 12);
    });
  }

  Widget _empty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: kPrimaryColor, size: 38),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            "No pending leave requests",
            style: textStyleMontserratBold(fontSize: 16, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            "You're all caught up with your team's approvals",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Details bottom sheet ────────────────────────────────────

  void _showDetails(TeamLeaveRequest r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailsSheet(
        request: r,
        onApprove: () {
          Get.back();
          _confirmAction(r, approve: true);
        },
        onReject: () {
          Get.back();
          _confirmAction(r, approve: false);
        },
      ),
    );
  }

  // ─── Approve / reject confirmation with optional remarks ─────

  void _confirmAction(TeamLeaveRequest r, {required bool approve}) {
    final remarksCtrl = TextEditingController();
    final color = approve ? kSecondaryColor : Colors.red;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      approve
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      approve ? "Approve Leave Request?" : "Reject Leave Request?",
                      style: textStyleMontserratBold(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _kv("Employee", "${r.displayName} (${r.employeeCode ?? '-'})"),
              _kv("Leave Type", r.leaveTypeName ?? '-'),
              _kv("Duration", _range(r)),
              const SizedBox(height: 12),
              TextField(
                controller: remarksCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: approve
                      ? "Remarks (optional)"
                      : "Reason for rejection (recommended)",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final remarks = remarksCtrl.text.trim();
                        if (approve) {
                          await c.approve(r.id, remarks: remarks);
                        } else {
                          await c.reject(r.id, remarks: remarks);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        approve ? "Approve" : "Reject",
                        style: textStyleMontserratBold(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                k,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: textStyleMontserratBold(
                  fontSize: 12.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );

  String _range(TeamLeaveRequest r) {
    final s = _fmt(r.startDate);
    final e = _fmt(r.endDate);
    final days = r.totalDays != null ? " (${r.totalDays} days)" : "";
    return "$s - $e$days";
  }

  static String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final d = DateTime.tryParse(raw);
    return d == null ? raw : DateFormat('MMM d, yyyy').format(d);
  }
}

// ─── Request Card ────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final TeamLeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamLeaveController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kPrimaryColor.withOpacity(0.12),
                child: Text(
                  request.initial,
                  style: textStyleMontserratBold(
                    fontSize: 15,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.displayName,
                      style: textStyleMontserratBold(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    if (request.employeeCode != null)
                      Text(
                        request.employeeCode!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.leaveTypeName ?? "Leave",
                  style: textStyleMontserratBold(
                    fontSize: 11,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.date_range_rounded,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _range(request),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (request.reason != null && request.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.reason!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          Obx(() {
            final busy = c.processingId.value == request.id;
            if (busy) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }
            return Row(
              children: [
                _OutlineBtn(
                  label: "View",
                  icon: Icons.visibility_outlined,
                  color: Colors.grey.shade700,
                  onTap: onView,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SolidBtn(
                    label: "Approve",
                    icon: Icons.check_rounded,
                    color: kSecondaryColor,
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SolidBtn(
                    label: "Reject",
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    onTap: onReject,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _range(TeamLeaveRequest r) {
    final s = _TeamLeaveRequestsScreenState._fmt(r.startDate);
    final e = _TeamLeaveRequestsScreenState._fmt(r.endDate);
    final days = r.totalDays != null ? " · ${r.totalDays}d" : "";
    return "$s → $e$days";
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolidBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SolidBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Details Sheet ───────────────────────────────────────────

class _DetailsSheet extends StatelessWidget {
  final TeamLeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DetailsSheet({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: kPrimaryColor.withOpacity(0.12),
                child: Text(
                  request.initial,
                  style: textStyleMontserratBold(
                    fontSize: 18,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.displayName,
                      style: textStyleMontserratBold(
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    if (request.employeeCode != null)
                      Text(
                        request.employeeCode!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _row("Leave Type", request.leaveTypeName ?? '-'),
          _row("Start Date", _TeamLeaveRequestsScreenState._fmt(request.startDate)),
          _row("End Date", _TeamLeaveRequestsScreenState._fmt(request.endDate)),
          _row("Total Days",
              request.totalDays != null ? "${request.totalDays}" : '-'),
          _row("Status", request.status ?? '-'),
          if (request.currentApproverName != null)
            _row("Approver", request.currentApproverName!),
          if (request.createdAt != null)
            _row("Requested On",
                _TeamLeaveRequestsScreenState._fmt(request.createdAt)),
          const SizedBox(height: 6),
          if (request.reason != null && request.reason!.isNotEmpty) ...[
            Text(
              "Reason",
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.reason!,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                k,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: textStyleMontserratBold(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
}
