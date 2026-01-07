import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/controllers/document_controller.dart';
import 'package:supergithr/screens/dashboard_screens/setting/doc/add_doc_screen.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/screens/dashboard_screens/setting/doc/document_viewer.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class PersonalDocumentsScreen extends StatefulWidget {
  PersonalDocumentsScreen({super.key});

  @override
  State<PersonalDocumentsScreen> createState() =>
      _PersonalDocumentsScreenState();
}

class _PersonalDocumentsScreenState extends State<PersonalDocumentsScreen> {
  final DocumentController _docController = Get.find<DocumentController>();

  @override
  void initState() {
    super.initState();
    // Fetch only if documents list is empty (first time)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📊 Personal Documents - List count: ${_docController.documents.length}');
      
      if (_docController.documents.isEmpty) {
        print('🔄 Fetching documents (list is empty)');
        _docController.fetchEmployeeDocuments();
      } else {
        print('✅ Using cached documents (${_docController.documents.length} items)');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(title: TranslationKeys.personalDocuments.tr),
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddDocumentScreen());
        },
        backgroundColor: kPrimaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        // Show shimmer only on initial load (empty list)
        if (_docController.isLoading.value && _docController.documents.isEmpty) {
          return _buildShimmerList();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _docController.fetchEmployeeDocuments();
          },
          color: kPrimaryColor,
          child:
              _docController.documents.isEmpty
                  ? _buildEmptyState()
                  : _buildDocumentsList(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              UIHelper.verticalSpaceSm20,
              kText(
                text: TranslationKeys.noDocumentsYet.tr,
                fSize: 20,
                fWeight: FontWeight.w600,
                tColor: Colors.grey.shade600,
              ),
              UIHelper.verticalSpaceSm10,
              kText(
                text: TranslationKeys.addFirstDocument.tr,
                fSize: 14,
                tColor: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      children: [
        // Header Stats
        _buildHeaderStats(),

        // Documents List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _docController.documents.length,
            separatorBuilder: (_, __) => UIHelper.verticalSpaceSm15,
            itemBuilder: (context, index) {
              final doc = _docController.documents[index];
              return _buildDocumentCard(doc);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    // Compute counts using reliable fields:
    // - verified: `isSigned == true` or signedAt contains 'verified'
    // - expired: expiry date before now
    // - pending: remaining documents (not verified and not expired)
    final now = DateTime.now();

    bool _isExpired(doc) {
      final expiry = doc.expiryDate;
      if (expiry == null || expiry.toString().trim().isEmpty) return false;
      // Try parsing common ISO-like formats
      DateTime? dt = DateTime.tryParse(expiry.toString());
      if (dt == null) {
        // Some APIs may return only date part; try adding time
        try {
          dt = DateTime.parse(expiry.toString());
        } catch (_) {
          return false;
        }
      }
      return dt.isBefore(now);
    }

    final verifiedCount =
        _docController.documents.where((doc) {
          final signedFlag = (doc.isSigned == true);
          final signedAt = (doc.signedAt ?? '').toString().toLowerCase();
          return signedFlag || signedAt.contains('verified');
        }).length;

    final expiredCount =
        _docController.documents.where((doc) => _isExpired(doc)).length;

    int pendingCount =
        _docController.documents.length - verifiedCount - expiredCount;
    if (pendingCount < 0) pendingCount = 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: linearGradient2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            verifiedCount,
            TranslationKeys.verified.tr,
            Colors.green.shade100,
            Colors.green,
          ),
          _buildStatItem(
            pendingCount,
            TranslationKeys.pending.tr,
            Colors.orange.shade100,
            Colors.orange,
          ),
          _buildStatItem(
            expiredCount,
            TranslationKeys.expired.tr,
            Colors.red.shade100,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _computeDocStatus(doc) {
    final now = DateTime.now();

    // expired check
    bool isExpired = false;
    final expiry = doc.expiryDate;
    if (expiry != null && expiry.toString().trim().isNotEmpty) {
      DateTime? dt = DateTime.tryParse(expiry.toString());
      if (dt != null) {
        isExpired = dt.isBefore(now);
      }
    }

    final signedFlag = (doc.isSigned == true);
    final signedAt = (doc.signedAt ?? '').toString().toLowerCase();

    if (signedFlag || signedAt.contains('verified')) {
      return {
        'label': TranslationKeys.verified.tr,
        'color': Colors.green,
        'icon': Icons.verified_rounded,
      };
    }

    if (isExpired || signedAt.contains('expired')) {
      return {
        'label': TranslationKeys.expired.tr,
        'color': Colors.red,
        'icon': Icons.error_outline_rounded,
      };
    }

    return {
      'label': TranslationKeys.pending.tr,
      'color': Colors.orange,
      'icon': Icons.pending_rounded,
    };
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    int count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: linearGradient3,
            shape: BoxShape.circle,
          ),
          child: kText(
            text: count.toString(),
            fSize: 18,
            fWeight: FontWeight.bold,
            tColor: Colors.white,
          ),
        ),
        UIHelper.verticalSpaceSm5,
        kText(
          text: label,
          fSize: 12,
          tColor: Colors.white.withOpacity(0.9),
          fWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildDocumentCard(doc) {
    final status = _computeDocStatus(doc);
    final Color statusColor = status['color'] as Color;
    final IconData statusIcon = status['icon'] as IconData;
    final String statusLabel = status['label'] as String;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: linearGradient2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: linearGradient3,
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: whiteColor,
                        size: 24,
                      ),
                    ),
                    UIHelper.horizontalSpaceSm15,

                    // Document Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kText(
                            text: doc.documentType ?? TranslationKeys.document.tr,
                            fSize: 18,
                            fWeight: FontWeight.bold,
                            tColor: whiteColor,
                          ),
                          UIHelper.verticalSpaceSm5,
                          kText(
                            text: doc.documentName ?? "-",
                            fSize: 14,
                            tColor: Colors.grey.shade200,
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: whiteColor, size: 16),
                          UIHelper.horizontalSpaceSm5,
                          kText(
                            text: statusLabel,
                            fSize: 12,
                            fWeight: FontWeight.w600,
                            tColor: whiteColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                UIHelper.verticalSpaceSm10,

                // Document Details
                _buildDetailGrid(doc),

                UIHelper.verticalSpaceSm10,

                // Action Buttons
                _buildActionButtons(doc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid(doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            TranslationKeys.documentNo.tr,
            doc.documentNumber ?? "-",
            Icons.numbers_rounded,
          ),
          _buildDetailItem(
            TranslationKeys.issueDate.tr,
            doc.issueDate ?? "-",
            Icons.calendar_today_rounded,
          ),
          _buildDetailItem(
            TranslationKeys.expiryDate.tr,
            doc.expiryDate ?? "-",
            Icons.event_busy_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          UIHelper.verticalSpaceSm5,
          kText(
            text: label,
            fSize: 10,
            tColor: Colors.grey.shade500,
            textalign: TextAlign.center,
          ),
          UIHelper.verticalSpaceSm5,
          kText(
            text: value,
            fSize: 12,
            fWeight: FontWeight.w600,
            tColor: Colors.grey.shade800,
            textalign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(doc) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Open document viewer
              Get.to(() => DocumentViewerScreen(filePath: doc.filePath ?? ''));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: whiteColor,
              side: BorderSide(color: whiteColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: kText(
              text: TranslationKeys.viewDocument.tr,
              fSize: 14,
              tColor: whiteColor,
              fWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
