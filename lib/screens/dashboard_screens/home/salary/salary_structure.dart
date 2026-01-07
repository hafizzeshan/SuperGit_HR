import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/salary_structure_controller.dart';
import 'package:supergithr/models/salary_structure_model.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class EmployeeSalaryStructureScreen extends StatefulWidget {
  EmployeeSalaryStructureScreen({super.key});

  @override
  State<EmployeeSalaryStructureScreen> createState() =>
      _EmployeeSalaryStructureScreenState();
}

class _EmployeeSalaryStructureScreenState
    extends State<EmployeeSalaryStructureScreen> {
  final SalaryStructureController controller =
      Get.find<SalaryStructureController>();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ✅ Fetch salary structure only if list is empty (first time)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📊 Salary Structure - List count: ${controller.salaryStructureList.length}');
      
      if (controller.salaryStructureList.isEmpty) {
        print('🔄 Fetching salary structure (list is empty)');
        controller.fetchSalaryStructureList();
      } else {
        print('✅ Using cached salary structure (${controller.salaryStructureList.length} items)');
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        controller.fetchSalaryStructureList(loadMore: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(title: TranslationKeys.salaryStructure.tr, titlefontSize: 18),
      backgroundColor: const Color(0xFFF3F4F7),

      body: Obx(() {
        // Show spinner only on initial load (empty list)
        if (controller.isLoading.value && controller.salaryStructureList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (controller.salaryStructureList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchSalaryStructureList(),
            color: kPrimaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 200),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Center(
                  child: kText(
                    text: TranslationKeys.noSalaryStructureAvailable.tr,
                    fSize: 14.0,
                    tColor: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: kText(
                    text: TranslationKeys.pullDownToRefresh.tr,
                    fSize: 12.0,
                    tColor: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSalaryStructureList,
          child: ListView.separated(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemCount: controller.salaryStructureList.length + 1,
            itemBuilder: (_, index) {
              if (index == controller.salaryStructureList.length) {
                return controller.isMoreLoading.value
                    ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox();
              }

              return _salaryTile(
                controller.salaryStructureList[index],
                context,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _salaryTile(SalaryDatum item, BuildContext context) {
    final totalAllowance =
        item.housingAllowance + item.transportAllowance + item.otherAllowances;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openBottomSheet(context, item),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --------------------------- Icon Badge ---------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: linearGradient3,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 16),

            // --------------------------- Salary Info ---------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: "${item.basicSalary} SAR",
                    fSize: 17,
                    fWeight: FontWeight.w700,
                    tColor: whiteColor,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      kText(
                        text: "${TranslationKeys.allowances.tr}: $totalAllowance",
                        fSize: 12,
                        tColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            _statusChip(item.isActive),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context, SalaryDatum item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.70,
          maxChildSize: 0.95,
          minChildSize: 0.50,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ListView(
                controller: scrollController,
                children: [
                  // --- Drag Handle ---
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // --- Header ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kText(
                            text: TranslationKeys.salaryBreakdown.tr,
                            fSize: 18,
                            fWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ],
                  ),

                  UIHelper.verticalSpaceSm20,

                  // --- Section: Main Salary ---
                  _sectionHeader(TranslationKeys.salaryComponents.tr),

                  _detailTile(
                    Icons.home,
                    TranslationKeys.housingAllowance.tr,
                    "${item.housingAllowance}",
                  ),
                  _detailTile(
                    Icons.directions_bus,
                    TranslationKeys.transportAllowance.tr,
                    "${item.transportAllowance}",
                  ),
                  _detailTile(
                    Icons.add_card,
                    TranslationKeys.otherAllowances.tr,
                    "${item.otherAllowances}",
                  ),

                  UIHelper.verticalSpaceSm20,

                  // --- Section: Deductions ---
                  _sectionHeader(TranslationKeys.deductions.tr),
                  _detailTile(
                    Icons.remove_circle,
                    TranslationKeys.deductions.tr,
                    "${item.deductions}",
                  ),
                  _detailTile(
                    Icons.security,
                    TranslationKeys.gosiContribution.tr,
                    "${item.gosiContribution}",
                  ),

                  UIHelper.verticalSpaceSm20,

                  // --- Section: Effective Dates ---
                  _sectionHeader(TranslationKeys.effectiveDates.tr),
                  _detailTile(
                    Icons.calendar_month,
                    TranslationKeys.effectiveFrom.tr,
                    item.effectiveFrom.year == 1
                        ? "-"
                        : item.effectiveFrom.toString().split(" ").first,
                  ),
                  _detailTile(
                    Icons.calendar_today,
                    TranslationKeys.effectiveTo.tr,
                    item.effectiveTo.year == 1
                        ? "-"
                        : item.effectiveTo.toString().split(" ").first,
                  ),

                  UIHelper.verticalSpaceSm20,
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: kText(
        text: title,
        fSize: 15,
        fWeight: FontWeight.bold,
        tColor: Colors.grey.shade800,
      ),
    );
  }

  Widget _detailTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: kText(text: title, fSize: 14)),
          kText(text: value, fSize: 15, fWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: kText(
        text: isActive ? TranslationKeys.active.tr : TranslationKeys.inactive.tr,
        fSize: 12,
        tColor: whiteColor,
        fWeight: FontWeight.w600,
      ),
    );
  }
}
