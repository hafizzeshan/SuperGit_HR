import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/ethics_controller.dart';
import 'package:supergithr/models/ethics_report_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/ethics/create_ethics_report_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/ethics/ethics_report_detail_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ethics_widgets.dart';

class EthicsReportsScreen extends StatefulWidget {
  const EthicsReportsScreen({super.key});

  @override
  State<EthicsReportsScreen> createState() => _EthicsReportsScreenState();
}

class _EthicsReportsScreenState extends State<EthicsReportsScreen> {
  final EthicsController _c = Get.put(EthicsController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 250) {
        _c.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openCreate() => Get.to(() => const CreateEthicsReportScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.ethicsReports.tr,
        context: context,
        actionwidget: IconButton(
          onPressed: _openCreate,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: kPrimaryColor, size: 22),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          final isFirstLoad = !_c.hasLoadedOnce.value && _c.isLoading.value;

          return RefreshIndicator(
            onRefresh: () => _c.fetchReports(force: true),
            color: kPrimaryColor,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                28,
              ).atLeastBottom(context.gestureInset + 8),
              children: [
                _introCard(),
                const SizedBox(height: 20),
                if (isFirstLoad)
                  const EthicsListShimmer()
                else if (_c.reports.isEmpty)
                  _emptyState()
                else ...[
                  _listHeader(),
                  const SizedBox(height: 12),
                  ..._c.reports.map(_reportCard),
                  if (_c.isLoadingMore.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _introCard() {
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
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(
                  text: TranslationKeys.ethicsIntroTitle.tr,
                  fSize: 17.0,
                  fWeight: FontWeight.w700,
                  tColor: Colors.white,
                ),
                const SizedBox(height: 4),
                kText(
                  text: TranslationKeys.ethicsIntroBody.tr,
                  fSize: 12.0,
                  tColor: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        kText(
          text: TranslationKeys.myReports.tr,
          fSize: 15.0,
          fWeight: FontWeight.w700,
          tColor: Colors.black87,
        ),
        kText(
          text: "${_c.reports.length}/${_c.totalRecords.value}",
          fSize: 12.5,
          fWeight: FontWeight.w600,
          tColor: Colors.grey.shade600,
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          kText(
            text: TranslationKeys.noEthicsReports.tr,
            fSize: 14.0,
            tColor: Colors.grey.shade500,
            textalign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _openCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            label: kText(
              text: TranslationKeys.newEthicsReport.tr,
              fSize: 14.0,
              fWeight: FontWeight.bold,
              tColor: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(EthicsReport report) {
    final statusColor = EthicsEnums.statusColor(report.status);
    final severityColor = EthicsEnums.severityColor(report.severity);
    final created =
        report.createdAt == null
            ? ''
            : DateFormat('dd MMM yyyy').format(report.createdAt!);

    return GestureDetector(
      onTap: () async {
        await Get.to(() => EthicsReportDetailScreen(reportId: report.id));
      },
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
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    EthicsEnums.categoryIcon(report.category),
                    size: 19,
                    color: severityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kText(
                        text: EthicsLabels.category(report.category),
                        fSize: 14.0,
                        fWeight: FontWeight.w700,
                        tColor: Colors.black87,
                        maxLines: 1,
                        textoverflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      kText(
                        text:
                            report.referenceNumber.isEmpty
                                ? created
                                : "${report.referenceNumber}  ·  $created",
                        fSize: 11.0,
                        tColor: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                EthicsBadge(
                  label: EthicsLabels.status(report.status),
                  color: statusColor,
                ),
              ],
            ),
            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              kText(
                text: report.description,
                fSize: 12.5,
                tColor: Colors.grey.shade700,
                height: 1.45,
                maxLines: 2,
                textoverflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                EthicsBadge(
                  label: EthicsLabels.severity(report.severity),
                  color: severityColor,
                  icon: Icons.flag_rounded,
                ),
                if (report.immediateDanger) ...[
                  const SizedBox(width: 8),
                  EthicsBadge(
                    label: TranslationKeys.urgent.tr,
                    color: const Color(0xffE05260),
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
                const Spacer(),
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
