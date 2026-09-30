import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/models/ethics_report_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/customText.dart';

/// Localised labels for the API's enum keys, kept in one place so the list,
/// form and detail screens can never drift apart.
class EthicsLabels {
  static String category(String key) => switch (key) {
    'harassment' => TranslationKeys.ethCatHarassment.tr,
    'discrimination' => TranslationKeys.ethCatDiscrimination.tr,
    'fraud' => TranslationKeys.ethCatFraud.tr,
    'safety_violation' => TranslationKeys.ethCatSafety.tr,
    'conflict_of_interest' => TranslationKeys.ethCatConflict.tr,
    'retaliation' => TranslationKeys.ethCatRetaliation.tr,
    _ => TranslationKeys.ethCatOther.tr,
  };

  static String status(EthicsStatus s) => switch (s) {
    EthicsStatus.pending => TranslationKeys.ethStatusPending.tr,
    EthicsStatus.underReview => TranslationKeys.ethStatusUnderReview.tr,
    EthicsStatus.investigating => TranslationKeys.ethStatusInvestigating.tr,
    EthicsStatus.resolved => TranslationKeys.ethStatusResolved.tr,
    EthicsStatus.closed => TranslationKeys.ethStatusClosed.tr,
  };

  static String severity(EthicsSeverity s) => switch (s) {
    EthicsSeverity.low => TranslationKeys.sevLow.tr,
    EthicsSeverity.medium => TranslationKeys.sevMedium.tr,
    EthicsSeverity.high => TranslationKeys.sevHigh.tr,
    EthicsSeverity.critical => TranslationKeys.sevCritical.tr,
  };
}

/// Small rounded pill used for status, severity and the urgent flag.
class EthicsBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const EthicsBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          kText(
            text: label,
            fSize: 11.0,
            fWeight: FontWeight.w600,
            tColor: color,
          ),
        ],
      ),
    );
  }
}

/// Placeholder cards matching [EthicsReportCard]'s shape.
class EthicsListShimmer extends StatelessWidget {
  const EthicsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h, [double r = 6]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    bar(38, 38, 12),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(120, 13),
                        const SizedBox(height: 7),
                        bar(84, 10),
                      ],
                    ),
                    const Spacer(),
                    bar(66, 22, 20),
                  ],
                ),
                const SizedBox(height: 14),
                bar(double.infinity, 11),
                const SizedBox(height: 7),
                bar(200, 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
