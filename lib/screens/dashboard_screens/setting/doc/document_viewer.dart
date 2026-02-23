import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

import 'package:supergithr/models/leave_request_model.dart';
import 'package:supergithr/models/employee_doc_model.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String? filePath;
  final String? status;
  final LeaveRequestModel? leave;
  final EmployeeDocumentModel? doc;

  const DocumentViewerScreen({
    super.key,
    required this.filePath,
    this.status,
    this.leave,
    this.doc,
  });

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final path = filePath ?? '';
    final fileName = path.split('/').last;

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.documentViewer.tr,
        titlefontSize: 18.0,
        actionwidget:
            path.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    Share.share(path, subject: fileName);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                )
                : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Column(
          children: [
            // TOP HALF: Document Container
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildContent(path),
                  ),
                ),
              ),
            ),

            // BOTTOM HALF: Status & Action Text
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: _buildStatusSection(path, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(String path, BuildContext context) {
    if (leave != null) {
      return _buildLeaveDetails(leave!);
    } else if (doc != null) {
      return _buildDocumentDetails(doc!);
    }

    final rawStatus = status?.toLowerCase() ?? "pending";
    Color accentColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_empty_rounded;

    if (rawStatus == "approved") {
      accentColor = Colors.green;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (rawStatus == "pending") {
      accentColor = Colors.orange;
      statusIcon = Icons.pending_actions_rounded;
    } else if (rawStatus == "rejected" || rawStatus == "cancelled") {
      accentColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: accentColor, size: 40),
        ),
        const SizedBox(height: 20),
        kText(
          text:
              status?.toUpperCase() ?? TranslationKeys.pending.tr.toUpperCase(),
          fSize: 22.0,
          fWeight: FontWeight.bold,
          tColor: mainBlackcolor,
        ),
        const SizedBox(height: 12),
        if (filePath != null)
          kText(
            text: filePath!.split('/').last,
            fSize: 14.0,
            tColor: Colors.grey.shade600,
          ),
        const Spacer(),
        if (path.isNotEmpty) _buildActionButtons(path, context),
      ],
    );
  }

  Widget _buildLeaveDetails(LeaveRequestModel leave) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _detailChip(
              leave.status?.toUpperCase() ??
                  TranslationKeys.pending.tr.toUpperCase(),
              _getStatusColor(leave.status),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDataRow(
                  Icons.calendar_today_rounded,
                  TranslationKeys.dateRange.tr,
                  "${leave.startDate} - ${leave.endDate}",
                ),
                _buildDataRow(
                  Icons.access_time_filled_rounded,
                  TranslationKeys.totalDays.tr,
                  "${leave.totalDays} ${TranslationKeys.days.tr}",
                ),
                _buildDataRow(
                  Icons.subject_rounded,
                  TranslationKeys.reason.tr,
                  leave.reason ?? "-",
                ),
                if (leave.approvedAt != null)
                  _buildDataRow(
                    Icons.verified_user_rounded,
                    TranslationKeys.approvedAt.tr,
                    leave.approvedAt!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filePath != null && filePath!.isNotEmpty)
          _buildActionButtons(filePath!, Get.context!),
      ],
    );
  }

  Widget _buildDocumentDetails(EmployeeDocumentModel doc) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _detailChip(doc.documentType ?? "DOCUMENT", kPrimaryColor),
            kText(
              text: "#${doc.documentNumber ?? '---'}",
              fSize: 14,
              fWeight: FontWeight.bold,
              tColor: Colors.grey.shade400,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDataRow(
                  Icons.badge_rounded,
                  TranslationKeys.documentName.tr,
                  doc.documentName ?? "-",
                ),
                _buildDataRow(
                  Icons.calendar_month_rounded,
                  TranslationKeys.issueDate.tr,
                  doc.issueDate ?? "-",
                ),
                _buildDataRow(
                  Icons.event_busy_rounded,
                  TranslationKeys.expiryDate.tr,
                  doc.expiryDate ?? "-",
                ),
                if (doc.signedAt != null)
                  _buildDataRow(
                    Icons.verified_rounded,
                    TranslationKeys.verified.tr,
                    doc.signedAt!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filePath != null && filePath!.isNotEmpty)
          _buildActionButtons(filePath!, Get.context!),
      ],
    );
  }

  Widget _detailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: kText(
        text: text,
        fSize: 12,
        fWeight: FontWeight.bold,
        tColor: color,
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(text: label, fSize: 12, tColor: Colors.grey.shade500),
                const SizedBox(height: 4),
                kText(
                  text: value,
                  fSize: 14,
                  fWeight: FontWeight.w600,
                  tColor: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildContent(String path) {
    if (path.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            UIHelper.verticalSpaceSm10,
            kText(
              text: TranslationKeys.noDocumentAvailable.tr,
              fSize: 16.0,
              tColor: Colors.grey,
            ),
          ],
        ),
      );
    }

    if (path.startsWith('http') && _isImage(path)) {
      return InteractiveViewer(
        maxScale: 5.0,
        minScale: 0.5,
        child: Image.network(
          path,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeWidth: 3,
                  ),
                  UIHelper.verticalSpaceSm15,
                  kText(
                    text: TranslationKeys.loading.tr,
                    fSize: 14.0,
                    tColor: kPrimaryColor,
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorState(),
        ),
      );
    }

    if (!kIsWeb && File(path).existsSync() && _isImage(path)) {
      return InteractiveViewer(
        maxScale: 5.0,
        child: Image.file(File(path), fit: BoxFit.contain),
      );
    }

    // Fallback for non-image or PDF
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 80,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            kText(
              text: path.split('/').last,
              textalign: TextAlign.center,
              fSize: 16.0,
              fWeight: FontWeight.bold,
              tColor: mainBlackcolor,
            ),
            const SizedBox(height: 8),
            kText(
              text: TranslationKeys.document.tr,
              fSize: 13.0,
              tColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red.shade300,
          ),
          UIHelper.verticalSpaceSm10,
          kText(
            text: TranslationKeys.failedToLoadImage.tr,
            fSize: 14.0,
            tColor: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String path, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.tryParse(path);
        if (uri != null) {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            Utils.snackBar(TranslationKeys.couldNotOpenDocument.tr, true);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: whiteColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: const Icon(Icons.open_in_new_rounded),
      label: kText(
        text: TranslationKeys.openDocument.tr,
        fSize: 16.0,
        tColor: whiteColor,
        fWeight: FontWeight.bold,
      ),
    );
  }
}
