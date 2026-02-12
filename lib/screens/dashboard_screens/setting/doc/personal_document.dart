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
import 'package:supergithr/views/custom_animated_views.dart';

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
      appBar: appBarrWitAction(
        title: TranslationKeys.personalDocuments.tr,
        actionwidget: IconButton(
          onPressed: () {
            Get.to(() => AddDocumentScreen());
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: kPrimaryColor, size: 22),
          ),
        ),
      ),
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: Obx(() {
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
      ),
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
    final docs = _docController.documents;

    // Filter into categories
    final idCards = docs.where((d) {
      final t = (d.documentType ?? "").toLowerCase();
      return t.contains("id") || t.contains("national") || t.contains("iqama");
    }).toList();

    final passports = docs.where((d) {
      final t = (d.documentType ?? "").toLowerCase();
      return t.contains("passport");
    }).toList();

    final visas = docs.where((d) {
      final t = (d.documentType ?? "").toLowerCase();
      return t.contains("visa");
    }).toList();

    final education = docs.where((d) {
      final t = (d.documentType ?? "").toLowerCase();
      return t.contains("degree") || t.contains("education") || t.contains("certificate");
    }).toList();

    // "Others" are those not in above lists
    final others = docs.where((d) {
      return !idCards.contains(d) && !passports.contains(d) && !visas.contains(d) && !education.contains(d);
    }).toList();


    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        // Header Stats
        _buildHeaderStats(),

        // Sections
        if (idCards.isNotEmpty) _buildDocTypeSection(TranslationKeys.idCards.tr, idCards),
        if (passports.isNotEmpty) _buildDocTypeSection(TranslationKeys.passport.tr, passports),
        if (visas.isNotEmpty) _buildDocTypeSection(TranslationKeys.visa.tr, visas),
        if (education.isNotEmpty) _buildDocTypeSection(TranslationKeys.education.tr, education),
        if (others.isNotEmpty) _buildDocTypeSection(TranslationKeys.others.tr, others),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDocTypeSection(String title, List<dynamic> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: kText(
            text: title,
            fSize: 16.0,
            fWeight: FontWeight.bold,
            tColor: Colors.black87,
          ),
        ),
        ...docs.map((doc) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: _buildDocumentCard(doc),
        )).toList(),
      ],
    );
  }

  Widget _buildHeaderStats() {
    // ... logic remains same ...
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            verifiedCount,
            TranslationKeys.verified.tr,
            Colors.green.shade50,
            Colors.green,
          ),
          _buildStatItem(
            pendingCount,
            TranslationKeys.pending.tr,
            Colors.orange.shade50,
            Colors.orange,
          ),
          _buildStatItem(
            expiredCount,
            TranslationKeys.expired.tr,
            Colors.red.shade50,
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status Icon Shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  UIHelper.horizontalSpaceSm15,

                  // Document Info Shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 150,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        UIHelper.verticalSpaceSm5,
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 100,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),
                  // Arrow Shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(color: Colors.grey.shade100, height: 32),

              // Document Details Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        UIHelper.verticalSpaceSm5,
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 60,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        UIHelper.verticalSpaceSm5,
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 40,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
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
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: kText(
            text: count.toString(),
            fSize: 18,
            fWeight: FontWeight.bold,
            tColor: textColor,
          ),
        ),
        UIHelper.verticalSpaceSm5,
        kText(
          text: label,
          fSize: 12,
          tColor: Colors.grey.shade600,
          fWeight: FontWeight.w600,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Get.to(() => DocumentViewerScreen(filePath: doc.filePath ?? ''));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Icon (Leading)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: statusColor.withOpacity(0.1),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    UIHelper.horizontalSpaceSm15,

                    // Document Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kText(
                            text: doc.documentType ?? TranslationKeys.document.tr,
                            fSize: 16,
                            fWeight: FontWeight.bold,
                            tColor: Colors.black87,
                          ),
                          UIHelper.verticalSpaceSm5,
                          kText(
                            text: doc.documentName ?? "-",
                            fSize: 13,
                            tColor: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),

                Divider(color: Colors.grey.shade100, height: 32),

                // Document Details
                _buildDetailGrid(doc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid(doc) {
    return Row(
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
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
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
            tColor: Colors.black87,
            textalign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
