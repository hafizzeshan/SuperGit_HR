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

/// Admin / HR view: work the incident queue and issue warning letters.
class DisciplineAdminScreen extends StatefulWidget {
  const DisciplineAdminScreen({super.key});

  @override
  State<DisciplineAdminScreen> createState() => _DisciplineAdminScreenState();
}

class _DisciplineAdminScreenState extends State<DisciplineAdminScreen>
    with SingleTickerProviderStateMixin {
  final DisciplineController _c = Get.put(DisciplineController());
  late final TabController _tabs = TabController(length: 2, vsync: this);

  static const List<IncidentStatus?> _filters = [
    null,
    IncidentStatus.open,
    IncidentStatus.underInvestigation,
    IncidentStatus.awaitingResponse,
    IncidentStatus.underReview,
    IncidentStatus.confirmed,
    IncidentStatus.rejected,
    IncidentStatus.closed,
  ];

  @override
  void initState() {
    super.initState();
    _c.loadAdminIncidents(force: true);
    _tabs.addListener(() {
      if (_tabs.index == 1 && _c.allWarnings.isEmpty) {
        _c.loadAdminWarnings(force: true);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── review sheet: confirm valid or reject invalid ──────────────────────

  Future<void> _openReview(DisciplineIncident incident) async {
    final comments = TextEditingController();

    await Get.bottomSheet(
      StatefulBuilder(
        builder:
            (context, _) => Container(
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
                    text: TranslationKeys.reviewDecision.tr,
                    fSize: 16.0,
                    fWeight: FontWeight.w700,
                    tColor: Colors.black87,
                  ),
                  if (incident.justification.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kMainBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: kPrimaryColor, width: 3),
                        ),
                      ),
                      child: kText(
                        text: incident.justification,
                        fSize: 12.5,
                        tColor: Colors.black87,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: comments,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: TranslationKeys.reviewComments.tr,
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await _c.review(
                              incident: incident,
                              valid: false,
                              comments: comments.text,
                            );
                            if (ok) Get.back();
                          },
                          icon: const Icon(Icons.close_rounded, size: 17),
                          label: kText(
                            text: TranslationKeys.rejectAsInvalid.tr,
                            fSize: 12.5,
                            fWeight: FontWeight.w600,
                            tColor: const Color(0xffEF4444),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xffEF4444),
                            side: const BorderSide(color: Color(0xffEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final ok = await _c.review(
                              incident: incident,
                              valid: true,
                              comments: comments.text,
                            );
                            if (ok) Get.back();
                          },
                          icon: const Icon(
                            Icons.check_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          label: kText(
                            text: TranslationKeys.confirmAsValid.tr,
                            fSize: 12.5,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff10B981),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
            ),
      ),
      isScrollControlled: true,
    );
  }

  // ── issue a warning letter against a confirmed incident ────────────────

  Future<void> _openIssueWarning() async {
    if (_c.confirmedIncidents.isEmpty) {
      Get.snackbar('', TranslationKeys.noConfirmedIncidents.tr);
      return;
    }

    DisciplineIncident selected = _c.confirmedIncidents.first;
    String type = DisciplineEnums.warningTypes[1];
    DateTime letterDate = DateTime.now();
    final content = TextEditingController();

    // Eligibility is checked as soon as an incident is picked, so HR sees the
    // threshold before writing the letter.
    _c.checkEligibility(selected.employeeId);

    await Get.bottomSheet(
      StatefulBuilder(
        builder:
            (context, setSheet) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: context.sheetPadding(),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
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
                      text: TranslationKeys.issueWarning.tr,
                      fSize: 16.0,
                      fWeight: FontWeight.w700,
                      tColor: Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    _label(TranslationKeys.selectConfirmedIncident.tr),
                    const SizedBox(height: 8),
                    _dropdown<DisciplineIncident>(
                      value: selected,
                      items: _c.confirmedIncidents,
                      labelOf:
                          (i) =>
                              "${i.employeeName} · "
                              "${i.incidentDate == null ? '' : DateFormat('d MMM').format(i.incidentDate!)}",
                      onChanged: (value) {
                        setSheet(() => selected = value);
                        _c.checkEligibility(value.employeeId);
                      },
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_c.isCheckingEligibility.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimaryColor,
                            ),
                          ),
                        );
                      }
                      final e = _c.eligibility.value;
                      if (e == null) return const SizedBox.shrink();
                      final color =
                          e.eligible
                              ? const Color(0xff10B981)
                              : const Color(0xffF59E0B);
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              e.eligible
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              size: 17,
                              color: color,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: kText(
                                text:
                                    "${e.eligible ? TranslationKeys.eligibleForWarning.tr : TranslationKeys.notEligibleForWarning.tr}: "
                                    "${e.confirmedCount} ${TranslationKeys.confirmedIncidentsCount.tr} · "
                                    "${TranslationKeys.threshold.tr} ${e.threshold}",
                                fSize: 11.5,
                                fWeight: FontWeight.w600,
                                tColor: color,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _label(TranslationKeys.warningType.tr),
                    const SizedBox(height: 8),
                    _dropdown<String>(
                      value: type,
                      items: DisciplineEnums.warningTypes,
                      labelOf: (t) => t,
                      onChanged: (value) => setSheet(() => type = value),
                    ),
                    const SizedBox(height: 16),
                    _label(TranslationKeys.letterDate.tr),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: letterDate,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 1),
                        );
                        if (picked != null) setSheet(() => letterDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: kMainBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            kText(
                              text: DateFormat(
                                'EEE, d MMM yyyy',
                              ).format(letterDate),
                              fSize: 13.0,
                              tColor: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label(TranslationKeys.letterContent.tr),
                    const SizedBox(height: 8),
                    TextField(
                      controller: content,
                      maxLines: 7,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: TranslationKeys.letterContent.tr,
                        hintStyle: TextStyle(
                          fontSize: 13.0,
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
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _c.isSubmitting.value
                                  ? null
                                  : () async {
                                    final ok = await _c.issueWarning(
                                      incident: selected,
                                      warningType: type,
                                      letterDate: letterDate,
                                      content: content.text,
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
                                    text: TranslationKeys.issueWarning.tr,
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
        title: TranslationKeys.manageDiscipline.tr,
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

  Widget _incidentsTab() => Column(
    children: [
      _filterBar(),
      Expanded(
        child: Obx(() {
          if (_c.isLoadingAdmin.value && _c.allIncidents.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _c.loadAdminIncidents(force: true),
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
                if (_c.allIncidents.isEmpty)
                  _empty(TranslationKeys.noIncidents.tr)
                else
                  ..._c.allIncidents.map(_adminIncidentCard),
              ],
            ),
          );
        }),
      ),
    ],
  );

  Widget _warningsTab() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _openIssueWarning,
            icon: const Icon(Icons.add, size: 19, color: Colors.white),
            label: kText(
              text: TranslationKeys.issueWarning.tr,
              fSize: 14.0,
              fWeight: FontWeight.w600,
              tColor: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: Obx(() {
          if (_c.isLoadingAdmin.value && _c.allWarnings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _c.loadAdminWarnings(force: true),
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
                if (_c.allWarnings.isEmpty)
                  _empty(TranslationKeys.noWarnings.tr)
                else
                  ..._c.allWarnings.map(_adminWarningCard),
              ],
            ),
          );
        }),
      ),
    ],
  );

  Widget _filterBar() => Obx(() {
    final active = _c.statusFilter.value;
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ).atLeastBottom(context.gestureInset + 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final status = _filters[index];
          final selected = active == status;
          return GestureDetector(
            onTap: () => _c.setStatusFilter(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? kPrimaryColor : Colors.grey.shade200,
                ),
              ),
              child: kText(
                text:
                    status == null
                        ? TranslationKeys.filterAll.tr
                        : DisciplineLabels.status(status),
                fSize: 12.0,
                fWeight: selected ? FontWeight.w600 : FontWeight.w500,
                tColor: selected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  });

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.only(top: 70),
    child: Column(
      children: [
        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        kText(text: text, fSize: 13.5, tColor: Colors.grey.shade500),
      ],
    ),
  );

  Widget _adminIncidentCard(DisciplineIncident incident) {
    final canReview = incident.status == IncidentStatus.underReview;

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
                radius: 18,
                backgroundColor: kPrimaryColor.withValues(alpha: 0.10),
                child: kText(
                  text:
                      incident.employeeName.isEmpty
                          ? '?'
                          : incident.employeeName[0].toUpperCase(),
                  fSize: 14.0,
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
                      text: incident.employeeName,
                      fSize: 13.0,
                      fWeight: FontWeight.w700,
                      tColor: Colors.black87,
                      maxLines: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    kText(
                      text: [
                        if (incident.incidentDate != null)
                          DateFormat(
                            'd MMM yyyy',
                          ).format(incident.incidentDate!),
                        if (incident.category.isNotEmpty) incident.category,
                      ].join('  ·  '),
                      fSize: 10.5,
                      tColor: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
              IncidentStatusBadge(status: incident.status),
            ],
          ),
          const SizedBox(height: 12),
          kText(
            text: incident.description,
            fSize: 12.5,
            tColor: Colors.grey.shade700,
            height: 1.45,
            maxLines: 3,
            textoverflow: TextOverflow.ellipsis,
          ),
          if (incident.justification.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: kMainBackgroundColor,
                borderRadius: BorderRadius.circular(11),
                border: const Border(
                  left: BorderSide(color: kPrimaryColor, width: 3),
                ),
              ),
              child: kText(
                text: incident.justification,
                fSize: 11.5,
                tColor: Colors.black87,
                height: 1.4,
                maxLines: 3,
                textoverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (incident.countsTowardWarning) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  size: 13,
                  color: Color(0xff10B981),
                ),
                const SizedBox(width: 6),
                kText(
                  text: TranslationKeys.countsTowardWarning.tr,
                  fSize: 11.0,
                  fWeight: FontWeight.w600,
                  tColor: const Color(0xff10B981),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          _actions(incident, canReview),
        ],
      ),
    );
  }

  /// Status moves live behind a menu; the review decision gets a real button
  /// because it is the one action that matters at that stage.
  Widget _actions(DisciplineIncident incident, bool canReview) {
    return Row(
      children: [
        if (incident.isEditableByAdmin)
          PopupMenuButton<IncidentStatus>(
            onSelected:
                (target) => _c.changeStatus(incident: incident, target: target),
            itemBuilder:
                (_) =>
                    DisciplineEnums.adminStatusTargets
                        .where((s) => s != incident.status)
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(
                                  DisciplineEnums.statusIcon(s),
                                  size: 16,
                                  color: DisciplineEnums.statusColor(s),
                                ),
                                const SizedBox(width: 10),
                                kText(
                                  text: DisciplineLabels.status(s),
                                  fSize: 12.5,
                                  tColor: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 17,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                kText(
                  text: TranslationKeys.statusUpdated.tr.split(' ').first,
                  fSize: 12.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        const Spacer(),
        InkWell(
          onTap: () => _c.deleteIncident(incident.id),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: Color(0xffEF4444),
            ),
          ),
        ),
        if (canReview)
          ElevatedButton.icon(
            onPressed: () => _openReview(incident),
            icon: const Icon(
              Icons.gavel_rounded,
              size: 15,
              color: Colors.white,
            ),
            label: kText(
              text: TranslationKeys.reviewDecision.tr,
              fSize: 12.0,
              fWeight: FontWeight.w600,
              tColor: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
      ],
    );
  }

  Widget _adminWarningCard(DisciplineWarning warning) {
    return GestureDetector(
      onTap: () => Get.to(() => WarningLetterScreen(warning: warning)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: WarningTypeBadge(warning: warning)),
                InkWell(
                  onTap: () => _c.deleteWarning(warning.id),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xffEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            kText(
              text: warning.employeeName,
              fSize: 13.0,
              fWeight: FontWeight.w700,
              tColor: Colors.black87,
            ),
            const SizedBox(height: 4),
            kText(
              text:
                  warning.letterDate == null
                      ? ''
                      : DateFormat('d MMM yyyy').format(warning.letterDate!),
              fSize: 11.0,
              tColor: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            kText(
              text: warning.content,
              fSize: 12.0,
              tColor: Colors.grey.shade700,
              height: 1.4,
              maxLines: 2,
              textoverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── small shared pieces ────────────────────────────────────────────────

  Widget _label(String text) => kText(
    text: text,
    fSize: 12.5,
    fWeight: FontWeight.w600,
    tColor: Colors.black87,
  );

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required void Function(T) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kMainBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(fontSize: 13.5, color: Colors.black87),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        labelOf(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
