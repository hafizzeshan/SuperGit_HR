import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/models/remote_work_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/customText.dart';

class RemoteLabels {
  static String status(RemoteStatus s) => switch (s) {
    RemoteStatus.pendingTeamLead => TranslationKeys.statusPendingTeamLead.tr,
    RemoteStatus.pendingAdmin => TranslationKeys.statusInAdminQueue.tr,
    RemoteStatus.approved => TranslationKeys.statusApproved.tr,
    RemoteStatus.rejected => TranslationKeys.statusRejected.tr,
  };
}

/// Status pill shared by the history cards and the approval cards.
class RemoteStatusBadge extends StatelessWidget {
  final RemoteStatus status;

  const RemoteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = RemoteWorkEnums.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(RemoteWorkEnums.statusIcon(status), size: 12, color: color),
          const SizedBox(width: 5),
          kText(
            text: RemoteLabels.status(status),
            fSize: 11.0,
            fWeight: FontWeight.w600,
            tColor: color,
          ),
        ],
      ),
    );
  }
}

/// One step of the three-stage approval trail.
class ApprovalTrailStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final bool isLast;

  const ApprovalTrailStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xff2E9E5B) : Colors.grey.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color, width: 1.2),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.6,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: color.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: title,
                    fSize: 12.5,
                    fWeight: FontWeight.w600,
                    tColor: done ? Colors.black87 : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 3),
                  kText(
                    text: subtitle,
                    fSize: 11.0,
                    tColor: Colors.grey.shade500,
                    height: 1.35,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
