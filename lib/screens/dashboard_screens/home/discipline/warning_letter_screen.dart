import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/models/discipline_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';

/// A warning letter rendered as a formal document rather than a list row —
/// this is an official record the employee may need to read carefully.
class WarningLetterScreen extends StatelessWidget {
  final DisciplineWarning warning;

  const WarningLetterScreen({super.key, required this.warning});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM yyyy');

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.warnings.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ).atLeastBottom(context.gestureInset + 8),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Letterhead
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: warning.accent.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: warning.accent.withValues(alpha: 0.30),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(AppAssets.logo, height: 44),
                        const SizedBox(height: 14),
                        kText(
                          text:
                              TranslationKeys.officialDisciplinaryNotice.tr
                                  .toUpperCase(),
                          fSize: 12.5,
                          fWeight: FontWeight.w700,
                          tColor: Colors.black87,
                          textalign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        WarningTypeChip(warning: warning),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _metaRow(
                          TranslationKeys.employee.tr,
                          warning.employeeName,
                        ),
                        _metaRow(
                          TranslationKeys.letterDate.tr,
                          warning.letterDate == null
                              ? '—'
                              : df.format(warning.letterDate!),
                        ),
                        if (warning.issuedByName.isNotEmpty)
                          _metaRow(
                            TranslationKeys.issuedBy.tr,
                            warning.issuedByName,
                          ),
                        if (warning.incidentId.isNotEmpty)
                          _metaRow(
                            TranslationKeys.incidentRef.tr,
                            warning.incidentId,
                          ),
                        const SizedBox(height: 8),
                        Container(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 18),
                        // The body keeps the author's line breaks.
                        kText(
                          text: warning.content,
                          fSize: 13.5,
                          tColor: Colors.black87,
                          height: 1.65,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.folder_shared_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: kText(
                      text: TranslationKeys.warningFileNotice.tr,
                      fSize: 11.5,
                      tColor: Colors.grey.shade600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: kText(text: label, fSize: 11.5, tColor: Colors.grey.shade600),
        ),
        Expanded(
          child: kText(
            text: value,
            fSize: 12.5,
            fWeight: FontWeight.w600,
            tColor: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

/// Large type chip used on the letterhead.
class WarningTypeChip extends StatelessWidget {
  final DisciplineWarning warning;

  const WarningTypeChip({super.key, required this.warning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: warning.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: kText(
        text: warning.warningType.toUpperCase(),
        fSize: 12.0,
        fWeight: FontWeight.w700,
        tColor: Colors.white,
        textalign: TextAlign.center,
      ),
    );
  }
}
