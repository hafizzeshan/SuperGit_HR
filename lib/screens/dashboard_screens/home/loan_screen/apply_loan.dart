import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';

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
  }

  // This function will calculate monthly installment
  double get monthlyInstallment {
    double amount =
        double.tryParse(_loanController.amountController.text) ?? 0.0;
    double monthlyInstallment = amount / 12;
    return monthlyInstallment > 100 ? 100 : monthlyInstallment;
  }

  // This function ensures that the start month is in the future
  // This function ensures that the start month is in the future
  Future<void> _pickStartMonth() async {
    DateTime currentDate = DateTime.now();
    DateTime firstSelectableDate = currentDate.add(
      Duration(days: 1),
    ); // Ensures it's at least tomorrow

    DateTime picked =
        await showDatePicker(
          context: context,
          initialDate:
              currentDate.isBefore(firstSelectableDate)
                  ? firstSelectableDate
                  : currentDate, // Ensure initialDate is not before firstSelectableDate
          firstDate:
              firstSelectableDate, // Restrict to future dates (tomorrow or later)
          lastDate: DateTime(
            currentDate.year + 1,
            12,
            31,
          ), // Allow up to a year
        ) ??
        currentDate;

    setState(() {
      _loanController.startMonthController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitoutAction(title: "Apply for Loan"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Installments and Monthly Installment at the top
            Text(
              "Installments: ${_loanController.installmentsController.text = "12"} months",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              "Monthly Installment: ${monthlyInstallment.toStringAsFixed(2)} SAR",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            // Loan Amount Field
            CustomTextField(
              controller: _loanController.amountController,
              hint: "Enter Loan Amount",
              keyboardType: TextInputType.number,
              required: true,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            // Start Month Field (Read-only, Date Picker)
            CustomTextField(
              controller: _loanController.startMonthController,
              hint: "Start Month (YYYY-MM)",
              readOnly: true,
              onTap: _pickStartMonth,
              required: true,
            ),
            const SizedBox(height: 12),

            // Purpose of Loan (Multi-line field)
            CustomTextField(
              controller: _loanController.purposeController,
              hint: "Purpose of Loan",
              required: true,
              maxLines: 4, // To allow multiple lines
            ),
            const SizedBox(height: 24),

            // Apply Loan Button
            LoadingButton(
              isLoading: _loanController.isSubmitting.value,
              text: "Apply for Loan",
              onTap: _applyLoan,
            ),
          ],
        ),
      ),
    );
  }

  // Apply Loan Action
  void _applyLoan() {
    _loanController.applyLoan();
  }
}
