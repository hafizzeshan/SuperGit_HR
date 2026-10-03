import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/discipline_controller.dart';
import 'package:supergithr/models/discipline_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/discipline/warning_letter_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/discipline_widgets.dart';

/// Employee view: incidents raised against them, and warning letters issued.
class DisciplineScreen extends StatefulWidget {
  const DisciplineScreen({super.key});

  @override
  State<DisciplineScreen> createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends State<DisciplineScreen>
    with SingleTickerProviderStateMixin {
  final DisciplineController _c = Get.put(DisciplineController());
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _c.loadMyIncidents(force: true);
    _c.loadMyWarnings(force: true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Bottom sheet where the employee writes or edits their explanation.
  Future<void> _openJustification(DisciplineIncident incident) async {
    final controller = TextEditingController(text: incident.justification);

    await Get.bottomSheet(
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
              text: TranslationKeys.justification.tr,
              fSize: 16.0,
              fWeight: FontWeight.w700,
              tColor: Colors.black87,
            ),
            const SizedBox(height: 10),
            // A reminder of what is being answered.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kMainBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: [
                      if (incident.incidentDate != null)
                        DateFormat('d MMM yyyy').format(incident.incidentDate!),
                      if (incident.category.isNotEmpty) incident.category,
                    ].join('  ·  '),
                    fSize: 11.0,
                    tColor: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 6),
                  kText(
                    text: incident.description,
                    fSize: 12.5,
                    tColor: Colors.black87,
                    height: 1.4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: TranslationKeys.explainWhatHappened.tr,
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
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _c.isSubmitting.value
                          ? null
                          : () async {
                            final ok = await _c.submitJustification(
                              incidentId: incident.id,
                              text: controller.text,
                            );
                            if (ok) Get.back();
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: kPrimaryColor.withValues(
                      alpha: 0.5,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      _c.isSubmitting.value
                          ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : kText(
                            text: TranslationKeys.submitJustification.tr,
                            fSize: 15.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.discipline.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Column(
          children: [
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_incidentsTab(), _warningsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: TabBar(
      controller: _tabs,
      indicator: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black87,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      tabs: [
        Tab(height: 38, text: TranslationKeys.incidents.tr),
        Tab(height: 38, text: TranslationKeys.warnings.tr),
      ],
    ),
  );

  Widget _incidentsTab() => Obx(() {
    final loading = _c.isLoadingIncidents.value && _c.myIncidents.isEmpty;
    return RefreshIndicator(
      onRefresh: () => _c.loadMyIncidents(force: true),
      color: kPrimaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          28,
        ).atLeastBottom(context.gestureInset + 8),
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            )
          else if (_c.myIncidents.isEmpty)
            _empty(Icons.verified_user_outlined, TranslationKeys.noIncidents.tr)
          else
            ..._c.myIncidents.map(_incidentCard),
        ],
      ),
    );
  });

  Widget _warningsTab() => Obx(() {
    final loading = _c.isLoadingWarnings.value && _c.myWarnings.isEmpty;
    return RefreshIndicator(
      onRefresh: () => _c.loadMyWarnings(force: true),
      color: kPrimaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          28,
        ).atLeastBottom(context.gestureInset + 8),
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            )
          else if (_c.myWarnings.isEmpty)
            _empty(Icons.gavel_rounded, TranslationKeys.noWarnings.tr)
          else
            ..._c.myWarnings.map(_warningCard),
        ],
      ),
    );
  });

  Widget _empty(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 70),
    child: Column(
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        kText(text: text, fSize: 13.5, tColor: Colors.grey.shade500),
      ],
    ),
  );

  Widget _incidentCard(DisciplineIncident incident) {
    final needsAction = incident.needsEmployeeAction;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              needsAction
                  ? const Color(0xffEA7A1E).withValues(alpha: 0.45)
                  : Colors.grey.shade200,
        ),
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
          // A banner, not just a badge — this one needs the employee to act.
          if (needsAction)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xffEA7A1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: kText(
                      text: TranslationKeys.justificationRequested.tr,
                      fSize: 11.5,
                      fWeight: FontWeight.w600,
                      tColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: kText(
                        text:
                            incident.incidentDate == null
                                ? '—'
                                : DateFormat(
                                  'EEE, d MMM yyyy',
                                ).format(incident.incidentDate!),
                        fSize: 13.0,
                        fWeight: FontWeight.w700,
                        tColor: Colors.black87,
                      ),
                    ),
                    IncidentStatusBadge(status: incident.status),
                  ],
                ),
                if (incident.category.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kMainBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: kText(
                      text: incident.category,
                      fSize: 11.0,
                      fWeight: FontWeight.w600,
                      tColor: Colors.grey.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                kText(
                  text: incident.description,
                  fSize: 12.5,
                  tColor: Colors.grey.shade700,
                  height: 1.45,
                  maxLines: 3,
                  textoverflow: TextOverflow.ellipsis,
                ),
                if (incident.justification.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _quote(
                    Icons.format_quote_rounded,
                    TranslationKeys.yourExplanation.tr,
                    incident.justification,
                    kPrimaryColor,
                  ),
                ],
                if (incident.reviewerComments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _quote(
                    Icons.gavel_rounded,
                    TranslationKeys.reviewerComments.tr,
                    incident.reviewerComments,
                    DisciplineEnums.statusColor(incident.status),
                  ),
                ],
                if (incident.canSubmitJustification) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openJustification(incident),
                      icon: Icon(
                        incident.justification.isEmpty
                            ? Icons.edit_note_rounded
                            : Icons.edit_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: kText(
                        text:
                            incident.justification.isEmpty
                                ? TranslationKeys.submitJustification.tr
                                : TranslationKeys.editJustification.tr,
                        fSize: 13.5,
                        fWeight: FontWeight.w600,
                        tColor: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            needsAction
                                ? const Color(0xffEA7A1E)
                                : kPrimaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quote(IconData icon, String label, String body, Color color) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kMainBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                kText(
                  text: label,
                  fSize: 11.0,
                  fWeight: FontWeight.w700,
                  tColor: color,
                ),
              ],
            ),
            const SizedBox(height: 6),
            kText(
              text: body,
              fSize: 12.0,
              tColor: Colors.black87,
              height: 1.45,
            ),
          ],
        ),
      );

  Widget _warningCard(DisciplineWarning warning) {
    return GestureDetector(
      onTap: () => Get.to(() => WarningLetterScreen(warning: warning)),
      child: Container(
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
                Expanded(child: WarningTypeBadge(warning: warning)),
                const SizedBox(width: 8),
                kText(
                  text:
                      warning.letterDate == null
                          ? ''
                          : DateFormat(
                            'd MMM yyyy',
                          ).format(warning.letterDate!),
                  fSize: 11.0,
                  tColor: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            kText(
              text: warning.content,
              fSize: 12.5,
              tColor: Colors.grey.shade700,
              height: 1.45,
              maxLines: 3,
              textoverflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: kText(
                    text: warning.issuedByName,
                    fSize: 11.0,
                    tColor: Colors.grey.shade600,
                    maxLines: 1,
                    textoverflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
