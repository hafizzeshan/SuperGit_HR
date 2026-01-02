import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/ui_helpers.dart';

class ProfileViewScreen extends StatelessWidget {
  ProfileViewScreen({super.key});

  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    // Ensure cached user is loaded
    _profileController.loadCachedUser();

    return Scaffold(
      appBar: appBarrWitAction(title: "Profile"),
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        final model = _profileController.userModel.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kText(text: "First Name", fSize: 12, tColor: Colors.grey),
                    UIHelper.verticalSpaceSm5,
                    kText(
                      text: model.firstNameEn ?? '-',
                      fSize: 16,
                      fWeight: FontWeight.w600,
                    ),
                    UIHelper.verticalSpaceSm10,

                    kText(text: "Last Name", fSize: 12, tColor: Colors.grey),
                    UIHelper.verticalSpaceSm5,
                    kText(
                      text: model.lastNameEn ?? '-',
                      fSize: 16,
                      fWeight: FontWeight.w600,
                    ),
                    UIHelper.verticalSpaceSm10,

                    kText(text: "Email", fSize: 12, tColor: Colors.grey),
                    UIHelper.verticalSpaceSm5,
                    kText(
                      text: model.email ?? '-',
                      fSize: 16,
                      fWeight: FontWeight.w600,
                    ),
                    UIHelper.verticalSpaceSm10,

                    kText(text: "Phone", fSize: 12, tColor: Colors.grey),
                    UIHelper.verticalSpaceSm5,
                    kText(
                      text: model.mobileNumber ?? '-',
                      fSize: 16,
                      fWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
