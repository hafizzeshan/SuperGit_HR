import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/custom_animated_views.dart';
import 'package:supergithr/models/user_model.dart';

class ProfileViewScreen extends StatelessWidget {
  ProfileViewScreen({super.key});

  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    // Ensure cached user is loaded
    _profileController.loadCachedUser();

    return Scaffold(
      appBar: appBarrWitAction(
        title: TranslationKeys.profile.tr,
        context: context,
      ),
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          final model = _profileController.userModel.value;

          return CustomAnimatedListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: 4, // Header + 3 Sections
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildProfileHeader(model);
                case 1:
                  return _buildSection(
                    title: TranslationKeys.contactInformation.tr,
                    children: [
                      _buildInfoTile(
                        Icons.email_outlined,
                        TranslationKeys.email.tr,
                        model.email,
                      ),
                      _buildInfoTile(
                        Icons.phone_android_rounded,
                        TranslationKeys.phone.tr,
                        model.mobileNumber,
                      ),
                      _buildInfoTile(
                        Icons.contact_phone_outlined,
                        TranslationKeys.emergencyContact.tr,
                        model.emergencyContactName,
                        subtitle: model.emergencyContactNumber,
                      ),
                    ],
                  );
                case 2:
                  return _buildSection(
                    title: TranslationKeys.workInformation.tr,
                    children: [
                      _buildInfoTile(
                        Icons.work_outline_rounded,
                        TranslationKeys.jobTitle.tr,
                        model.jobTitle,
                      ),
                      _buildInfoTile(
                        Icons.badge_outlined,
                        TranslationKeys.employeeCode.tr,
                        model.employeeCode,
                      ),
                      // field removed
                      _buildInfoTile(
                        Icons.assignment_ind_outlined,
                        TranslationKeys.jobRoleId.tr,
                        model.jobRoleId,
                      ),
                      _buildInfoTile(
                        Icons.verified_user_outlined,
                        TranslationKeys.employmentStatus.tr,
                        model.employmentStatus,
                      ),
                      _buildInfoTile(
                        Icons.calendar_month_outlined,
                        TranslationKeys.joinDate.tr,
                        _formatDate(model.joinDate),
                      ),
                      _buildInfoTile(
                        Icons.supervised_user_circle_outlined,
                        TranslationKeys.manager.tr,
                        (model.managerName != null &&
                                model.managerName!.isNotEmpty)
                            ? model.managerName
                            : model.managerId,
                      ),
                    ],
                  );
                case 3:
                  return _buildSection(
                    title: TranslationKeys.personalInformation.tr,
                    children: [
                      _buildInfoTile(
                        Icons.person_outline_rounded,
                        TranslationKeys.gender.tr,
                        model.gender,
                      ),
                      _buildInfoTile(
                        Icons.cake_outlined,
                        TranslationKeys.dateOfBirth.tr,
                        _formatDate(model.dateOfBirth),
                      ),
                      _buildInfoTile(
                        Icons.flag_outlined,
                        TranslationKeys.nationality.tr,
                        model.nationality,
                      ),
                      _buildInfoTile(
                        Icons.description_outlined,
                        TranslationKeys.documentID.tr,
                        model.documentId,
                      ),
                      _buildInfoTile(
                        Icons.favorite_border_rounded,
                        TranslationKeys.maritalStatus.tr,
                        model.maritalStatus,
                      ),
                    ],
                  );
                default:
                  return const SizedBox();
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel model) {
    final fullName =
        "${model.firstNameEn ?? ''} ${model.lastNameEn ?? ''}".trim();
    final parts =
        fullName.split(' ').where((e) => e.isNotEmpty).take(2).toList();
    final initials =
        parts.isNotEmpty ? parts.map((e) => e[0].toUpperCase()).join() : "U";

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: kPrimaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.08),
              child: kText(
                text: initials.toUpperCase(),
                fSize: 22,
                fWeight: FontWeight.bold,
                tColor: kPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          kText(
            text: fullName.isNotEmpty ? fullName : TranslationKeys.user.tr,
            fSize: 18,
            fWeight: FontWeight.bold,
            tColor: Colors.black87,
            letterSpacing: -0.5,
            textalign: TextAlign.center,
            maxLines: 1,
            textoverflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          if (model.jobTitle != null && model.jobTitle!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: kText(
                text: model.jobTitle!,
                fSize: 13,
                fWeight: FontWeight.w600,
                tColor: kPrimaryColor,
                maxLines: 1,
                textoverflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    // Filter out null/empty children
    final validChildren = children.where((c) => c is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
          child: kText(
            text: title,
            fSize: 14,
            fWeight: FontWeight.bold,
            tColor: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < validChildren.length; i++) ...[
                validChildren[i],
                if (i != validChildren.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                    indent: 52, // Align with text start
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String? value, {
    String? subtitle,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                kText(
                  text: label,
                  fSize: 12,
                  tColor: Colors.grey.shade500,
                  fWeight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                kText(
                  text: value,
                  fSize: 15,
                  tColor: Colors.black87,
                  fWeight: FontWeight.w600,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  kText(
                    text: subtitle,
                    fSize: 13,
                    tColor: Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
