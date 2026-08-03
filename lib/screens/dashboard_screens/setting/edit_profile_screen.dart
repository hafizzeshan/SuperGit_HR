import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/ui_helpers.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final ProfileController _profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: TranslationKeys.editProfile.tr,
        context: context,
        actionwidget: IconButton(
          icon: const Icon(Icons.check, color: Colors.black87),
          onPressed: () async {
            if (_formKey.currentState?.validate() != true) return;
            final success = await _profileController.updateProfile();
            if (success) Get.back();
          },
        ),
      ),
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarPicker(),
                const SizedBox(height: 16),
                _buildSectionTitle(TranslationKeys.personalInformation.tr),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.givenNameController,
                  hint: TranslationKeys.name.tr,
                  required: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.familyNameController,
                  hint: TranslationKeys.name.tr,
                  required: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.nationalIdController,
                  hint: TranslationKeys.documentID.tr,
                  required: true,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.nationalityController,
                  hint: TranslationKeys.nationality.tr,
                  required: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.genderController,
                  hint: TranslationKeys.gender.tr,
                  required: true,
                  readOnly: true,
                  onTap: () {
                    UIHelper().showGenderBottomSheet(
                      context: context,
                      onTapM: () {
                        _profileController.genderController.text =
                            TranslationKeys.male.tr;
                        Get.back();
                      },
                      onTapF: () {
                        _profileController.genderController.text =
                            TranslationKeys.female.tr;
                        Get.back();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.dateOfBirthController,
                  hint: TranslationKeys.dateOfBirth.tr,
                  required: true,
                  readOnly: true,
                  onTap: () async {
                    final picked = await UIHelper().selectDate(context);
                    if (picked != null) {
                      _profileController.dateOfBirthController.text =
                          picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(TranslationKeys.contactInformation.tr),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.phoneController,
                  hint: TranslationKeys.phone.tr,
                  required: true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _profileController.emailController,
                  hint: TranslationKeys.email.tr,
                  required: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;
                    final success = await _profileController.updateProfile();
                    if (success) Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Center(
                    child: kText(
                      text: TranslationKeys.saveChanges.tr,
                      fSize: 16,
                      fWeight: FontWeight.w700,
                      tColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return kText(
      text: title,
      fSize: 14,
      fWeight: FontWeight.bold,
      tColor: Colors.black87,
    );
  }

  Widget _buildAvatarPicker() {
    return Obx(() {
      final avatarUrl = _profileController.userModel.value.avatarUrl;
      final selectedAvatar = _profileController.selectedAvatar.value;
      final imageProvider =
          selectedAvatar != null && selectedAvatar.path != null
              ? FileImage(File(selectedAvatar.path!)) as ImageProvider
              : (avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _profileController.pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage: imageProvider,
                  child:
                      imageProvider == null
                          ? kText(
                            text: TranslationKeys.user.tr,
                            fSize: 18,
                            fWeight: FontWeight.bold,
                            tColor: kPrimaryColor,
                          )
                          : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          kText(
            text: TranslationKeys.pickImage.tr,
            fSize: 14,
            fWeight: FontWeight.w600,
            tColor: Colors.black54,
          ),
        ],
      );
    });
  }
}
