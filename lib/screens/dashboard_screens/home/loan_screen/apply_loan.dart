import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  _ApplyLoanScreenState createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final LoanController _loanController = Get.find<LoanController>();

  @override
  void initState() {
    super.initState();
    // Clear form to ensure no stale data remains when navigating
    _loanController.clearForm();

    // Set default value
    if (_loanController.installmentsController.text.isEmpty) {
      _loanController.installmentsController.text = "12";
    }
  }

  // Calculate monthly installment based on input amount
  double get monthlyInstallment {
    double amount = double.tryParse(_loanController.amountController.text) ?? 0.0;
    // Assuming fixed 12 months as per code logic
    return amount / 12; 
  }

  // Date Picker Logic
  Future<void> _pickStartMonth() async {
    DateTime currentDate = DateTime.now();
    DateTime firstSelectableDate = currentDate.add(const Duration(days: 1)); 

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstSelectableDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime(currentDate.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _loanController.startMonthController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: TranslationKeys.applyForLoan.tr),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Summary Card ---
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // --- Amount Field ---
            _buildLabel(TranslationKeys.amount.tr),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _loanController.amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: TranslationKeys.enterLoanAmount.tr,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.money, color: Colors.grey.shade400),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- Start Month (Date Picker) ---
            _buildLabel(TranslationKeys.startMonth.tr),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickStartMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: kPrimaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _loanController.startMonthController.text.isNotEmpty
                            ? _loanController.startMonthController.text
                            : TranslationKeys.selectDate.tr,
                        style: TextStyle(
                          color: _loanController.startMonthController.text.isNotEmpty
                              ? Colors.black87
                              : Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Purpose Field ---
            _buildLabel(TranslationKeys.purposeOfLoan.tr),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _loanController.purposeController,
                maxLines: 4,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: TranslationKeys.addReasonForLeave.tr, // Reusing similar hint
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- Submit Button ---
            Obx(() => LoadingButton(
                  isLoading: _loanController.isSubmitting.value,
                  text: TranslationKeys.applyForLoan.tr,
                  onTap: _applyLoan,
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Row(
      children: [
        Expanded(
          child: _summaryCardItem(
            TranslationKeys.installments.tr,
            "12 ${TranslationKeys.months.tr}",
            Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryCardItem(
            TranslationKeys.monthlyInstallment.tr,
            "${monthlyInstallment.toStringAsFixed(2)} SAR",
            Icons.payments_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryCardItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  void _applyLoan() {
    _loanController.applyLoan();
  }
}
