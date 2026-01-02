import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:supergithr/controllers/document_controller.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';

class AddDocumentScreen extends StatefulWidget {
  AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final DocumentController controller = Get.find<DocumentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitoutAction(title: "Add Document"),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomTextField(
                controller: controller.documentTypeController,
                hint: "Document Type",
                required: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.documentNameController,
                hint: "Document Name",
                required: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.documentNumberController,
                hint: "Document Number",
                required: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.issueDateController,
                hint: "Issue Date",
                readOnly: true,
                onTap: () => _pickDate(controller.issueDateController),
                required: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.expiryDateController,
                hint: "Expiry Date",
                readOnly: true,
                onTap: () => _pickDate(controller.expiryDateController),
                required: true,
              ),
              const SizedBox(height: 12),
              _buildFilePickerField(),
              const SizedBox(height: 24),
              LoadingButton(
                isLoading: !controller.isSubmitting.value,
                text: "Add Document",
                onTap: controller.addDocument,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.image, allowMultiple: false);
                  if (result != null && result.files.single.path != null) {
                    controller.filePathController.text =
                        result.files.single.path!;
                    setState(() {}); // Update UI immediately
                    print("selected image ${result.files.single.path}");
                  }
                },
                text:
                    controller.filePathController.text.isEmpty
                        ? "Browse"
                        : "Change File",
                circleRadius: 10.0,
                height: 45.0,
              ),
            ),
            if (controller.filePathController.text.isNotEmpty) ...[
              UIHelper.horizontalSpaceSm10,
              Expanded(
                flex: 2,
                child: Text(
                  controller.filePathController.text.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),

        // Image preview section
        if (controller.filePathController.text.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.verticalSpaceSm20,
              kText(
                text: "Selected Image:",
                fSize: 14.0,
                fWeight: FontWeight.w500,
                tColor: Colors.grey.shade700,
              ),
              UIHelper.verticalSpaceSm10,
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(controller.filePathController.text),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40,
                            ),
                            UIHelper.verticalSpaceSm10,
                            kText(
                              text: "Failed to load image",
                              fSize: 14.0,
                              tColor: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              UIHelper.verticalSpaceSm10,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.filePathController.clear();
                      setState(() {}); // Refresh UI immediately
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Remove image",
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }
}
