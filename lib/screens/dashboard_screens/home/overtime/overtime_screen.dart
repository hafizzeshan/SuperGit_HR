import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/overtime_controller.dart';
import 'package:supergithr/models/overtime_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/overtime/create_overtime_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/localization_helper.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final OvertimeController _c = Get.find<OvertimeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_c.overtimes.isEmpty) _c.fetchOvertimes();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _c.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return kSecondaryColor;
      case 'pending':
        return const Color(0xffF2A33C);
      case 'rejected':
      case 'cancelled':
        return const Color(0xffE05260);
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.overtime.tr,
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
          if (_c.isLoading.value && _c.overtimes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _c.fetchOvertimes(page: 1),
            color: kPrimaryColor,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _summaryCard(),
                const SizedBox(height: 20),
                if (_c.overtimes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TranslationKeys.overtimeRequests.tr,
                        style: textStyleMontserratBold(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "${_c.overtimes.length}/${_c.totalRecords.value}",
                        style: textStyleMontserratMiddle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._c.overtimes.map(_overtimeTile),
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
                ] else
                  _emptyState(),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: _openCreate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          TranslationKeys.requestOvertime.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _openCreate() {
    Get.to(() => const CreateOvertimeScreen());
  }

  /// Gradient hero card with the total logged overtime + status breakdown.
  Widget _summaryCard() {
    final totalHours = _c.totalHours;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: linearGradient2,
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.more_time_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.totalOvertime.tr,
                      style: textStyleMontserratMiddle(
                        fontSize: 12.0,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${totalHours.toStringAsFixed(2)} ${TranslationKeys.hours.tr}",
                      style: textStyleMontserratBold(
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  TranslationKeys.pendingRequests.tr,
                  "${_c.pendingCount}",
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _summaryStat(
                  TranslationKeys.approvedRequests.tr,
                  "${_c.approvedCount}",
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _summaryStat(
                  TranslationKeys.total.tr,
                  "${_c.totalRecords.value}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: textStyleMontserratBold(fontSize: 17.0, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyleMontserratMiddle(
            fontSize: 11.0,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _overtimeTile(OvertimeDatum item) {
    final color = _statusColor(item.status);
    final date = item.date;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsSheet(item, color),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date block
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        date == null ? "--" : DateFormat('dd').format(date),
                        style: textStyleMontserratBold(
                          fontSize: 18.0,
                          color: color,
                        ),
                      ),
                      Text(
                        date == null ? "" : DateFormat('MMM').format(date),
                        style: textStyleMontserratMiddle(
                          fontSize: 11.0,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.durationLabel,
                            style: textStyleMontserratBold(
                              fontSize: 15.0,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          _statusPill(item.status, color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.reason.isNotEmpty
                            ? item.reason
                            : "${TranslationKeys.overtimeHours.tr}: ${item.overtimeHours}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyleMontserratRegular(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _miniChip(
                            Icons.timelapse_rounded,
                            "${item.overtimeHours} ${TranslationKeys.hours.tr}",
                          ),
                          const SizedBox(width: 8),
                          if (item.overtimeAmount > 0)
                            _miniChip(
                              Icons.payments_rounded,
                              "${item.overtimeAmount}",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        LocalizationHelper.getLoanStatus(status),
        style: textStyleMontserratBold(fontSize: 10.0, color: color),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kPrimaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: textStyleMontserratMiddle(
              fontSize: 10.0,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(
            Icons.more_time_rounded,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.noOvertimeFound.tr,
            style: textStyleMontserratMiddle(
              fontSize: 15.0,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TranslationKeys.pullDownToRefresh.tr,
            style: textStyleMontserratRegular(
              fontSize: 12.0,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsSheet(OvertimeDatum item, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            gradient: kMainBackgroundGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_time_rounded,
                    color: color,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  item.durationLabel,
                  style: textStyleMontserratBold(
                    fontSize: 22.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                _statusPill(item.status, color),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _detailRow(
                        TranslationKeys.date.tr,
                        item.date == null
                            ? "-"
                            : DateFormat('dd MMM yyyy').format(item.date!),
                      ),
                      _detailRow(
                        TranslationKeys.duration.tr,
                        "${item.durationMinutes} ${TranslationKeys.minutes.tr}",
                      ),
                      _detailRow(
                        TranslationKeys.overtimeHours.tr,
                        "${item.overtimeHours}",
                      ),
                      _detailRow(
                        TranslationKeys.overtimeRate.tr,
                        "${item.overtimeRate}",
                      ),
                      _detailRow(
                        TranslationKeys.hourlyRate.tr,
                        "${item.hourlyRate}",
                      ),
                      _detailRow(
                        TranslationKeys.overtimeAmount.tr,
                        "${item.overtimeAmount}",
                      ),
                      _detailRow(
                        TranslationKeys.requestedOn.tr,
                        item.createdAt == null
                            ? "-"
                            : DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(item.createdAt!),
                        isLast: item.reason.isEmpty,
                      ),
                      if (item.reason.isNotEmpty) ...[
                        const Divider(height: 24),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            TranslationKeys.reason.tr,
                            style: textStyleMontserratMiddle(
                              fontSize: 13.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            item.reason,
                            style: textStyleMontserratMiddle(
                              fontSize: 13.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textStyleMontserratMiddle(
              fontSize: 13.0,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textStyleMontserratBold(
                fontSize: 13.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
