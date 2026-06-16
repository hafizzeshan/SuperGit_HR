import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/announcement_controller.dart';
import 'package:supergithr/models/announcement_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/custom_animated_views.dart';
import 'package:supergithr/views/announcement_bottom_sheet.dart';

import 'package:supergithr/views/appBar.dart';

class AnnouncementsListScreen extends StatelessWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnouncementController controller = Get.find<AnnouncementController>();

    return Scaffold(
      backgroundColor: kMainBackgroundColor, // Match Home background
      appBar: appBarrWitAction(title: TranslationKeys.announcements.tr),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: () => controller.fetchAnnouncements(),
          color: kPrimaryColor,
          child: Obx(() {
            if (controller.isLoading.value && controller.announcements.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }

            if (controller.announcements.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: Get.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          TranslationKeys.noAnnouncementsAvailable.tr,
                          style: textStyleMontserratBold(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAnimatedGridView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8, // Taller cards to match home style
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.announcements.length,
                itemBuilder: (context, index) {
                  final announcement = controller.announcements[index];
                  return _buildGridAnnouncementCard(context, announcement, index);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGridAnnouncementCard(BuildContext context, AnnouncementData announcement, int index) {
    final title = announcement.title ?? TranslationKeys.announcement.tr;
    final message = announcement.message ?? TranslationKeys.tapToViewDetails.tr;
    final date = announcement.publishAt != null
        ? DateFormat('dd MMM', Get.locale?.languageCode).format(DateTime.parse(announcement.publishAt!))
        : TranslationKeys.today.tr;
    final time = announcement.publishAt != null
         ? DateFormat('HH:mm', Get.locale?.languageCode).format(DateTime.parse(announcement.publishAt!))
         : "";

    // Alternate card styles for visual variety
    final isSecondary = index % 2 != 0;
     final bgGradient = isSecondary
        ? const LinearGradient(
            colors: [Color(0xffE8F0F2), Color(0xffE8F0F2)],
          )
        : const LinearGradient(
            colors: [Color(0xffE3EEFF), Color(0xffF0F6FF)], // Bluish
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: () => _showAnnouncementDetail(context, title, message, date: "$date • $time"),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(30), // Rounded modern style
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      date,
                      style: textStyleMontserratBold(
                        fontSize: 10.0,
                        color: Colors.black54,
                      ),
                    ),
                   ),
                ],
             ),
            const Spacer(),
            Text(
              title,
              style: textStyleMontserratBold(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              message,
               style: textStyleMontserratMiddle(
                fontSize: 11.0,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xff2A2A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(BuildContext context, String title, String body, {String? date}) {
    AnnouncementBottomSheet.show(
      context: context,
      title: title,
      body: body,
      date: date,
    );
  }
}
