import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/models/loan_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/loan_screen/apply_loan.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

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
      appBar: appBarrWitoutAction(title: TranslationKeys.loans.tr),
      body: Obx(() {
        // Show loading only on first load
        if (_loanController.isLoading.value &&
            _loanController.loans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
            itemCount: _loanController.loans.length,
            itemBuilder: (_, index) {
              final loan = _loanController.loans[index];
              return _loanTile(loan);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(ApplyLoanScreen());
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
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
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          kText(
            text: TranslationKeys.noLoansFound.tr,
            fSize: 18.0,
            fWeight: FontWeight.w600,
            tColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          kText(
            text: TranslationKeys.pullDownToRefresh.tr,
            fSize: 14.0,
            tColor: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _loanTile(LoanDatum loan) {
    // Determine the loan status color
    Color statusColor = loan.status == "Pending" ? Colors.orange : Colors.green;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Loan Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: linearGradient2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.money_rounded, color: Colors.white, size: 30),
            ),
            UIHelper.horizontalSpaceSm15,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: loan.purpose,
                    fSize: 16.0,
                    fWeight: FontWeight.w700,
                    tColor: Colors.white,
                  ),
                  UIHelper.verticalSpaceSm5,
                  kText(
                    text: "${TranslationKeys.amount.tr}: ${loan.amount}",
                    fSize: 14.0,
                    tColor: Colors.grey.shade200,
                  ),
                  UIHelper.verticalSpaceSm5,
                  kText(
                    text: "${TranslationKeys.remaining.tr}: ${loan.remainingAmount}",
                    fSize: 14.0,
                    tColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
            // Loan Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: kText(
                text: loan.status,
                fSize: 12.0,
                tColor: Colors.white,
                fWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
