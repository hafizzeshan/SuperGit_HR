import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/models/loan_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/loan_screen/apply_loan.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/localization_helper.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  _LoanScreenState createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final LoanController _loanController = Get.find<LoanController>();

  @override
  void initState() {
    super.initState();
    // Fetch loans on first load if list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_loanController.loans.isEmpty) {
        _loanController.fetchLoans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.loans.tr,
        actionwidget: IconButton(
          onPressed: () {
            Get.to(() => ApplyLoanScreen());
          },
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
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: Obx(() {
          // Show loading only on first load
          if (_loanController.isLoading.value &&
              _loanController.loans.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (_loanController.loans.isEmpty &&
              !_loanController.isLoading.value) {
            return _buildEmptyState();
          }

          // Add pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => _loanController.fetchLoans(),
            color: kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _loanController.loans.length,
              itemBuilder: (_, index) {
                final loan = _loanController.loans[index];
                return _loanTile(loan);
              },
            ),
          );
        }),
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.money_off_rounded,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          kText(
            text: TranslationKeys.noLoansFound.tr,
            fSize: 15.0,
            tColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          kText(
            text: TranslationKeys.pullDownToRefresh.tr,
            fSize: 12.0,
            tColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _loanTile(LoanDatum loan) {
    Color statusColor = loan.status.toLowerCase() == "approved"
        ? Colors.green
        : loan.status.toLowerCase() == "pending"
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLoanDetailsBottomSheet(context, loan, statusColor),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kText(
                            text: loan.purpose,
                            fSize: 16,
                            fWeight: FontWeight.bold,
                            tColor: Colors.black87,
                          ),
                          const SizedBox(height: 4),
                          kText(
                            text: LocalizationHelper.getLoanStatus(loan.status),
                            fSize: 12,
                            fWeight: FontWeight.w600,
                            tColor: statusColor,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _infoChip(
                        TranslationKeys.amount.tr,
                        "${loan.amount}",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoChip(
                        TranslationKeys.remaining.tr,
                        "${loan.remainingAmount}",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoanDetailsBottomSheet(
      BuildContext context, LoanDatum loan, Color statusColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                const SizedBox(height: 30),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: statusColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                kText(
                  text: LocalizationHelper.getLoanStatus(loan.status),
                  fSize: 22,
                  fWeight: FontWeight.bold,
                  tColor: statusColor,
                ),
                const SizedBox(height: 8),
                kText(
                  text: "${TranslationKeys.amount.tr}: ${loan.amount}",
                  fSize: 15,
                  tColor: Colors.grey.shade600,
                ),
                const SizedBox(height: 30),

                // Details Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _detailRow(TranslationKeys.purpose.tr, loan.purpose),
                      const SizedBox(height: 16),
                      _detailRow(TranslationKeys.installments.tr, "${loan.installments}"),
                      const SizedBox(height: 16),
                      _detailRow(TranslationKeys.monthlyInstallment.tr, "${loan.monthlyInstallment}"),
                      const SizedBox(height: 16),
                      _detailRow(TranslationKeys.startMonth.tr, loan.startMonth),
                      const SizedBox(height: 16),
                      _detailRow(
                          TranslationKeys.remaining.tr, "${loan.remainingAmount}"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        kText(
          text: label,
          fSize: 14,
          tColor: Colors.grey.shade600,
        ),
        kText(
          text: value,
          fSize: 14,
          fWeight: FontWeight.bold,
          tColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _infoChip(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(
            text: title,
            fSize: 10.0,
            tColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 4),
          kText(
            text: value,
            fSize: 12.0,
            fWeight: FontWeight.w600,
            tColor: Colors.black87,
            maxLines: 1,
            textoverflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
