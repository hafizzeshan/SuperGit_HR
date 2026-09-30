import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/ethics_controller.dart';
import 'package:supergithr/models/ethics_report_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ethics_widgets.dart';

/// New report, or editing an existing one while it is still pending.
class CreateEthicsReportScreen extends StatefulWidget {
  final EthicsReport? existing;

  const CreateEthicsReportScreen({super.key, this.existing});

  @override
  State<CreateEthicsReportScreen> createState() =>
      _CreateEthicsReportScreenState();
}

class _CreateEthicsReportScreenState extends State<CreateEthicsReportScreen> {
  final EthicsController _c = Get.put(EthicsController());

  final _locationController = TextEditingController();
  final _peopleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = '';
  EthicsSeverity _severity = EthicsSeverity.medium;
  DateTime? _incidentDate;
  bool _immediateDanger = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _c.clearDraft();
    final existing = widget.existing;
    if (existing != null) {
      _category = existing.category;
      _severity = existing.severity;
      _incidentDate = existing.incidentDate;
      _immediateDanger = existing.immediateDanger;
      _locationController.text = existing.incidentLocation;
      _peopleController.text = existing.peopleInvolved;
      _descriptionController.text = existing.description;
    }
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _locationController.dispose();
    _peopleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? now,
      firstDate: DateTime(now.year - 5),
      // The service rejects incidents dated in the future.
      lastDate: now,
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: kPrimaryColor),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _incidentDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok =
        _isEditing
            ? await _c.updateReport(
              id: widget.existing!.id,
              category: _category,
              severity: _severity,
              description: _descriptionController.text,
              immediateDanger: _immediateDanger,
              incidentDate: _incidentDate,
              incidentLocation: _locationController.text,
              peopleInvolved: _peopleController.text,
            )
            : await _c.submit(
              category: _category,
              severity: _severity,
              description: _descriptionController.text,
              immediateDanger: _immediateDanger,
              incidentDate: _incidentDate,
              incidentLocation: _locationController.text,
              peopleInvolved: _peopleController.text,
            );
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final length = _descriptionController.text.trim().length;

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title:
            _isEditing
                ? TranslationKeys.updateReport.tr
                : TranslationKeys.newEthicsReport.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(TranslationKeys.category.tr),
                  const SizedBox(height: 10),
                  _categoryPicker(),
                  const SizedBox(height: 22),
                  _label(TranslationKeys.severity.tr),
                  const SizedBox(height: 10),
                  _severityPicker(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(
                    "${TranslationKeys.incidentDate.tr}  ·  ${TranslationKeys.optional.tr}",
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: kMainBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 17,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 12),
                          kText(
                            text:
                                _incidentDate == null
                                    ? TranslationKeys.incidentDate.tr
                                    : DateFormat(
                                      'EEE, d MMM yyyy',
                                    ).format(_incidentDate!),
                            fSize: 13.5,
                            tColor:
                                _incidentDate == null
                                    ? Colors.grey.shade400
                                    : Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _label(
                    "${TranslationKeys.incidentLocation.tr}  ·  ${TranslationKeys.optional.tr}",
                  ),
                  const SizedBox(height: 8),
                  _field(
                    controller: _locationController,
                    hint: TranslationKeys.incidentLocation.tr,
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 18),
                  _label(
                    "${TranslationKeys.peopleInvolved.tr}  ·  ${TranslationKeys.optional.tr}",
                  ),
                  const SizedBox(height: 8),
                  _field(
                    controller: _peopleController,
                    hint: TranslationKeys.peopleInvolved.tr,
                    icon: Icons.people_alt_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _label(TranslationKeys.description.tr),
                      kText(
                        text: "$length/20",
                        fSize: 11.5,
                        fWeight: FontWeight.w600,
                        tColor:
                            length >= 20
                                ? const Color(0xff2E9E5B)
                                : Colors.grey.shade500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _field(
                    controller: _descriptionController,
                    hint: TranslationKeys.describeIncident.tr,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _dangerCard(),
            const SizedBox(height: 14),
            _attachmentsCard(),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _c.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: kPrimaryColor.withValues(
                      alpha: 0.5,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      _c.isSubmitting.value
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : kText(
                            text:
                                _isEditing
                                    ? TranslationKeys.updateReport.tr
                                    : TranslationKeys.submitReport.tr,
                            fSize: 15.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          EthicsEnums.categories.map((key) {
            final selected = _category == key;
            return GestureDetector(
              onTap: () => setState(() => _category = key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? kPrimaryColor : kMainBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? kPrimaryColor : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      EthicsEnums.categoryIcon(key),
                      size: 15,
                      color: selected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 7),
                    kText(
                      text: EthicsLabels.category(key),
                      fSize: 12.5,
                      fWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      tColor: selected ? Colors.white : Colors.black87,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _severityPicker() {
    return Row(
      children:
          EthicsSeverity.values.map((severity) {
            final selected = _severity == severity;
            final color = EthicsEnums.severityColor(severity);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _severity = severity),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? color.withValues(alpha: 0.12)
                            : kMainBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? color : Colors.grey.shade200,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: kText(
                    text: EthicsLabels.severity(severity),
                    fSize: 12.0,
                    fWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    tColor: selected ? color : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _dangerCard() {
    return GestureDetector(
      onTap: () => setState(() => _immediateDanger = !_immediateDanger),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              _immediateDanger
                  ? const Color(0xffE05260).withValues(alpha: 0.07)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _immediateDanger
                    ? const Color(0xffE05260)
                    : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color:
                  _immediateDanger
                      ? const Color(0xffE05260)
                      : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: TranslationKeys.immediateDanger.tr,
                    fSize: 13.5,
                    fWeight: FontWeight.w700,
                    tColor: Colors.black87,
                  ),
                  const SizedBox(height: 3),
                  kText(
                    text: TranslationKeys.immediateDangerHint.tr,
                    fSize: 11.5,
                    tColor: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ],
              ),
            ),
            Switch(
              value: _immediateDanger,
              activeThumbColor: const Color(0xffE05260),
              onChanged: (v) => setState(() => _immediateDanger = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label(TranslationKeys.attachments.tr),
              TextButton.icon(
                onPressed: _c.pickFiles,
                icon: const Icon(Icons.attach_file_rounded, size: 17),
                label: kText(
                  text: TranslationKeys.addAttachment.tr,
                  fSize: 12.5,
                  fWeight: FontWeight.w600,
                  tColor: kPrimaryColor,
                ),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
              ),
            ],
          ),
          kText(
            text: TranslationKeys.fileTooLargeMax10Mb.tr,
            fSize: 11.0,
            tColor: Colors.grey.shade500,
          ),
          Obx(() {
            if (_c.pickedFiles.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: _c.pickedFiles.map(_pickedFileRow).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pickedFileRow(PlatformFile file) {
    final sizeMb = file.size / (1024 * 1024);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kMainBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 18,
            color: kPrimaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(
                  text: file.name,
                  fSize: 12.5,
                  fWeight: FontWeight.w600,
                  tColor: Colors.black87,
                  maxLines: 1,
                  textoverflow: TextOverflow.ellipsis,
                ),
                kText(
                  text:
                      sizeMb >= 1
                          ? "${sizeMb.toStringAsFixed(1)} MB"
                          : "${(file.size / 1024).round()} KB",
                  fSize: 10.5,
                  tColor: Colors.grey.shade500,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _c.removePickedFile(file),
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ── shared pieces ──────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );

  Widget _label(String text) => kText(
    text: text,
    fSize: 13.0,
    fWeight: FontWeight.w600,
    tColor: Colors.black87,
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
        prefixIcon:
            icon == null
                ? null
                : Icon(icon, size: 19, color: Colors.grey.shade500),
        filled: true,
        fillColor: kMainBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.4),
        ),
      ),
    );
  }
}
