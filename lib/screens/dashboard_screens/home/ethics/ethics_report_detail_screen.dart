import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/ethics_controller.dart';
import 'package:supergithr/models/ethics_report_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/ethics/create_ethics_report_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ethics_widgets.dart';
import 'package:supergithr/views/full_image_view.dart';
import 'package:url_launcher/url_launcher.dart';

class EthicsReportDetailScreen extends StatefulWidget {
  final String reportId;

  const EthicsReportDetailScreen({super.key, required this.reportId});

  @override
  State<EthicsReportDetailScreen> createState() =>
      _EthicsReportDetailScreenState();
}

class _EthicsReportDetailScreenState extends State<EthicsReportDetailScreen> {
  final EthicsController _c = Get.put(EthicsController());

  @override
  void initState() {
    super.initState();
    _c.selectedReport.value = null;
    _c.loadDetails(widget.reportId);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: kText(
          text: TranslationKeys.deleteReportConfirm.tr,
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
              text: TranslationKeys.delete.tr,
              fSize: 13.5,
              fWeight: FontWeight.w600,
              tColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _c.deleteReport(widget.reportId);
      if (ok) Get.back();
    }
  }

  Future<void> _openAttachment(EthicsAttachment attachment) async {
    if (attachment.fileUrl.isEmpty) return;
    if (attachment.isImage) {
      Get.to(
        () => FullImageViewScreen(
          imageUrl: attachment.fileUrl,
          heroTag: attachment.id,
        ),
      );
      return;
    }
    final uri = Uri.tryParse(attachment.fileUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.reportDetails.tr,
        context: context,
        actionwidget: Obx(() {
          final report = _c.selectedReport.value;
          // Editing and deleting are only offered while HR has not started.
          if (report == null || !report.isEditable) {
            return const SizedBox(width: 8);
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await Get.to(
                    () => CreateEthicsReportScreen(existing: report),
                  );
                  _c.loadDetails(widget.reportId);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: kPrimaryColor,
                  size: 21,
                ),
              ),
              IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xffE05260),
                  size: 21,
                ),
              ),
            ],
          );
        }),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          final report = _c.selectedReport.value;
          if (report == null) {
            return Center(
              child:
                  _c.isLoadingDetail.value
                      ? const CircularProgressIndicator(color: kPrimaryColor)
                      : kText(
                        text: TranslationKeys.noDataFound.tr,
                        fSize: 14.0,
                        tColor: Colors.grey,
                      ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _c.loadDetails(widget.reportId),
            color: kPrimaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                30,
              ).atLeastBottom(context.gestureInset + 8),
              children: [
                _summaryCard(report),
                const SizedBox(height: 14),
                _detailsCard(report),
                if (report.resolutionSummary.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _resolutionCard(report),
                ],
                if (report.attachments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _attachmentsCard(report),
                ],
                const SizedBox(height: 14),
                _updatesCard(report),
                if (report.isEditable) ...[
                  const SizedBox(height: 14),
                  _pendingHint(),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryCard(EthicsReport report) {
    final statusColor = EthicsEnums.statusColor(report.status);
    final severityColor = EthicsEnums.severityColor(report.severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xff00A3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: Icon(
                  EthicsEnums.categoryIcon(report.category),
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kText(
                      text: EthicsLabels.category(report.category),
                      fSize: 16.5,
                      fWeight: FontWeight.w700,
                      tColor: Colors.white,
                    ),
                    if (report.referenceNumber.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      kText(
                        text: report.referenceNumber,
                        fSize: 12.0,
                        tColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _whiteBadge(EthicsLabels.status(report.status), statusColor),
              _whiteBadge(
                EthicsLabels.severity(report.severity),
                severityColor,
              ),
              if (report.immediateDanger)
                _whiteBadge(TranslationKeys.urgent.tr, const Color(0xffE05260)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whiteBadge(String label, Color dotColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 7),
        kText(
          text: label,
          fSize: 11.5,
          fWeight: FontWeight.w600,
          tColor: Colors.white,
        ),
      ],
    ),
  );

  Widget _detailsCard(EthicsReport report) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.createdAt != null)
            _row(
              Icons.schedule_rounded,
              TranslationKeys.submittedOn.tr,
              DateFormat('EEE, d MMM yyyy · hh:mm a').format(report.createdAt!),
            ),
          if (report.incidentDate != null)
            _row(
              Icons.event_rounded,
              TranslationKeys.incidentDate.tr,
              DateFormat('EEE, d MMM yyyy').format(report.incidentDate!),
            ),
          if (report.incidentLocation.isNotEmpty)
            _row(
              Icons.place_outlined,
              TranslationKeys.incidentLocation.tr,
              report.incidentLocation,
            ),
          if (report.peopleInvolved.isNotEmpty)
            _row(
              Icons.people_alt_outlined,
              TranslationKeys.peopleInvolved.tr,
              report.peopleInvolved,
            ),
          const SizedBox(height: 6),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),
          kText(
            text: TranslationKeys.description.tr,
            fSize: 12.5,
            fWeight: FontWeight.w600,
            tColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 7),
          kText(
            text: report.description,
            fSize: 13.5,
            tColor: Colors.black87,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _resolutionCard(EthicsReport report) {
    const green = Color(0xff2E9E5B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: green.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: green, size: 19),
              const SizedBox(width: 9),
              kText(
                text: TranslationKeys.resolution.tr,
                fSize: 13.5,
                fWeight: FontWeight.w700,
                tColor: green,
              ),
            ],
          ),
          const SizedBox(height: 10),
          kText(
            text: report.resolutionSummary,
            fSize: 13.0,
            tColor: Colors.black87,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard(EthicsReport report) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(
            text:
                "${TranslationKeys.attachments.tr} (${report.attachments.length})",
            fSize: 13.5,
            fWeight: FontWeight.w700,
            tColor: Colors.black87,
          ),
          const SizedBox(height: 12),
          ...report.attachments.map(
            (attachment) => _attachmentRow(report, attachment),
          ),
        ],
      ),
    );
  }

  Widget _attachmentRow(EthicsReport report, EthicsAttachment attachment) {
    return GestureDetector(
      onTap: () => _openAttachment(attachment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kMainBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child:
                  attachment.isImage
                      ? Image.network(
                        attachment.fileUrl,
                        height: 42,
                        width: 42,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                _fileIcon(Icons.broken_image_outlined),
                      )
                      : _fileIcon(Icons.description_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: attachment.fileName,
                    fSize: 12.5,
                    fWeight: FontWeight.w600,
                    tColor: Colors.black87,
                    maxLines: 1,
                    textoverflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  kText(
                    text: attachment.readableSize,
                    fSize: 10.5,
                    tColor: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            if (report.isEditable)
              IconButton(
                onPressed:
                    () => _c.deleteAttachment(
                      reportId: report.id,
                      attachmentId: attachment.id,
                    ),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fileIcon(IconData icon) => Container(
    height: 42,
    width: 42,
    color: kPrimaryColor.withValues(alpha: 0.08),
    child: Icon(icon, size: 20, color: kPrimaryColor),
  );

  Widget _updatesCard(EthicsReport report) {
    // Internal HR notes are filtered out by the model — the reporter only ever
    // sees public updates.
    final notes = report.visibleNotes;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_outlined, size: 18, color: kPrimaryColor),
              const SizedBox(width: 9),
              kText(
                text: TranslationKeys.updatesFromHr.tr,
                fSize: 13.5,
                fWeight: FontWeight.w700,
                tColor: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (notes.isEmpty)
            kText(
              text: TranslationKeys.noUpdatesYet.tr,
              fSize: 12.5,
              tColor: Colors.grey.shade500,
            )
          else
            ...notes.map(
              (note) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kMainBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: kPrimaryColor, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: kText(
                            text: note.authorName,
                            fSize: 12.0,
                            fWeight: FontWeight.w700,
                            tColor: kPrimaryColor,
                          ),
                        ),
                        if (note.createdAt != null)
                          kText(
                            text: DateFormat(
                              'd MMM · hh:mm a',
                            ).format(note.createdAt!),
                            fSize: 10.5,
                            tColor: Colors.grey.shade500,
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    kText(
                      text: note.message,
                      fSize: 12.5,
                      tColor: Colors.black87,
                      height: 1.45,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pendingHint() => Row(
    children: [
      Icon(Icons.info_outline_rounded, size: 15, color: Colors.grey.shade500),
      const SizedBox(width: 7),
      Expanded(
        child: kText(
          text: TranslationKeys.editableOnlyWhilePending.tr,
          fSize: 11.5,
          tColor: Colors.grey.shade600,
        ),
      ),
    ],
  );

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: kPrimaryColor),
        const SizedBox(width: 12),
        kText(text: label, fSize: 12.5, tColor: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: kText(
            text: value,
            fSize: 12.5,
            fWeight: FontWeight.w600,
            tColor: Colors.black87,
            textalign: TextAlign.end,
          ),
        ),
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}
