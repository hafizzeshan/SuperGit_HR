import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/models/discipline_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/customText.dart';

class DisciplineLabels {
  static String status(IncidentStatus s) => switch (s) {
    IncidentStatus.open => TranslationKeys.statusOpen.tr,
    IncidentStatus.underInvestigation =>
      TranslationKeys.statusUnderInvestigation.tr,
    IncidentStatus.awaitingResponse =>
      TranslationKeys.statusAwaitingResponse.tr,
    IncidentStatus.underReview => TranslationKeys.statusUnderReview.tr,
    IncidentStatus.confirmed => TranslationKeys.statusConfirmed.tr,
    IncidentStatus.rejected => TranslationKeys.statusRejected.tr,
    IncidentStatus.closed => TranslationKeys.statusClosed.tr,
  };
}

/// Status pill used on every incident card.
class IncidentStatusBadge extends StatelessWidget {
  final IncidentStatus status;

  const IncidentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = DisciplineEnums.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(DisciplineEnums.statusIcon(status), size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: kText(
              text: DisciplineLabels.status(status),
              fSize: 10.5,
              fWeight: FontWeight.w600,
              tColor: color,
              maxLines: 1,
              textoverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured strip that marks the severity of a warning letter.
class WarningTypeBadge extends StatelessWidget {
  final DisciplineWarning warning;

  const WarningTypeBadge({super.key, required this.warning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: warning.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gavel_rounded, size: 13, color: warning.accent),
          const SizedBox(width: 6),
          Flexible(
            child: kText(
              text: warning.warningType.toUpperCase(),
              fSize: 10.5,
              fWeight: FontWeight.w700,
              tColor: warning.accent,
              maxLines: 1,
              textoverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
