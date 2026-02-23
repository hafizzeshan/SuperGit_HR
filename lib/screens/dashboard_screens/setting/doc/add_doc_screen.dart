import 'dart:io';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:supergithr/controllers/document_controller.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final DocumentController controller = Get.find<DocumentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: TranslationKeys.addDocument.tr),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(TranslationKeys.documentDetails.tr),
                const SizedBox(height: 16),

                // Document Type Selector
                GestureDetector(
                  onTap: _showDocTypeSelector,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: (Get.locale?.languageCode == 'ur' || Get.locale?.languageCode == 'ar') ? TextDirection.rtl : TextDirection.ltr,
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: kText(
                              text: controller.documentTypeController.text.isNotEmpty
                                  ? controller.documentTypeController.text
                                  : TranslationKeys.documentType.tr,
                              fSize: 15.0,
                              textalign: TextAlign.start,
                              fWeight: controller.documentTypeController.text.isNotEmpty
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              tColor: controller.documentTypeController.text.isNotEmpty
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Document Name
                CustomTextField(
                  controller: controller.documentNameController,
                  hint: TranslationKeys.documentName.tr,
                  required: true,
                  prefix: Icon(
                    Icons.description_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // Document Number
                CustomTextField(
                  controller: controller.documentNumberController,
                  hint: TranslationKeys.documentNumber.tr,
                  required: true,
                  maxLength: 15,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  prefix: Icon(
                    Icons.numbers,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(TranslationKeys.validityPeriod.tr),
                const SizedBox(height: 16),

                // Dates Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(controller.issueDateController),
                        child: _buildDateField(
                          TranslationKeys.issueDate.tr,
                          controller.issueDateController.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(controller.expiryDateController),
                        child: _buildDateField(
                          TranslationKeys.expiryDate.tr,
                          controller.expiryDateController.text,
                          isExpiry: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(TranslationKeys.upload.tr),
                const SizedBox(height: 16),
                _buildFilePickerField(),

                const SizedBox(height: 40),

                // Submit Button
                LoadingButton(
                  isLoading: controller.isSubmitting.value,
                  text: TranslationKeys.addDocument.tr,
                  onTap: controller.addDocument,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDocTypeSelector() {
    final List<Map<String, dynamic>> docTypes = [
      {'name': TranslationKeys.nationalID, 'icon': Icons.badge_outlined, 'color': Colors.blue},
      {'name': TranslationKeys.iqama, 'icon': Icons.perm_identity, 'color': Colors.indigo},
      {'name': TranslationKeys.passport, 'icon': Icons.book_outlined, 'color': Colors.purple},
      {'name': TranslationKeys.visa, 'icon': Icons.airplane_ticket_outlined, 'color': Colors.orange},
      {'name': TranslationKeys.degreeCertificate, 'icon': Icons.school_outlined, 'color': Colors.green},
      {'name': TranslationKeys.others, 'icon': Icons.folder_open_outlined, 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  kText(
                    text: TranslationKeys.selectDocumentType.tr,
                    fSize: 18.0,
                    fWeight: FontWeight.bold,
                    tColor: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: docTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final type = docTypes[index];
                  return InkWell(
                    onTap: () {
                      controller.documentTypeController.text = type['name'].toString().tr;
                      Get.back();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (type['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type['icon'] as IconData,
                              color: type['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          kText(
                            text: type['name'].toString().tr,
                            fSize: 16.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.black87,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return kText(
      text: title,
      fSize: 16.0,
      fWeight: FontWeight.bold,
      tColor: Colors.black87,
    );
  }

  Widget _buildDateField(String label, String value, {bool isExpiry = false}) {
    final hasValue = value.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(text: label, fSize: 12.0, tColor: Colors.grey.shade600),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isExpiry ? Colors.red.shade400 : kPrimaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: kText(
                  text: hasValue ? value : TranslationKeys.selectDate.tr,
                  fSize: 14.0,
                  fWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                  tColor: hasValue ? Colors.black87 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerField() {
    final hasFile = controller.filePathController.text.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          controller.filePathController.text = result.files.single.path!;
          setState(() {});
        }
      },
      child:
          hasFile
              ? _buildFilePreview()
              : DottedBorder(
                // borderType: BorderType.RRect, // Removed as it caused an error
                // radius: const Radius.circular(16),
                // padding: const EdgeInsets.all(0),
                // color: kPrimaryColor.withOpacity(0.4),
                // strokeWidth: 2,
                // dashPattern: const [8, 4],
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_rounded,
                          color: kPrimaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      kText(
                        text: TranslationKeys.browse.tr,
                        fSize: 16.0,
                        fWeight: FontWeight.w600,
                        tColor: kPrimaryColor,
                      ),
                      const SizedBox(height: 8),
                      kText(
                        text: TranslationKeys.supportsJpgPng.tr,
                        fSize: 12.0,
                        tColor: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFilePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(controller.filePathController.text),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      kText(
                        text: TranslationKeys.failedToLoadImage.tr,
                        fSize: 14.0,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              controller.filePathController.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.filePathController.text.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                kText(
                  text: TranslationKeys.changeFile.tr,
                  fSize: 12.0,
                  fWeight: FontWeight.w600,
                  tColor: kPrimaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController textController) async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        textController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
