import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/announcement_controller.dart';
import 'package:supergithr/models/announcement_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class AnnouncementsListScreen extends StatelessWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnouncementController controller = Get.find<AnnouncementController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarrWitoutAction(
        title: TranslationKeys.announcements,
        context: context,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.announcements.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }

        if (controller.announcements.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchAnnouncements(),
            color: kPrimaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 200),
                Icon(
                  Icons.campaign_outlined,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Center(
                  child: kText(
                     text: TranslationKeys.noAnnouncementsAvailable.tr,
                     fSize: 14,
                     tColor: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: kText(
                    text: TranslationKeys.pullDownToRefresh.tr,
                    fSize: 12.0,
                    tColor: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnnouncements(),
          color: kPrimaryColor,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final announcement = controller.announcements[index];
              return _announcementItem(context, announcement);
            },
          ),
        );
      }),
    );
  }

  Widget _announcementItem(BuildContext context, AnnouncementData announcement) {
    final title = announcement.title ?? "";
    final message = announcement.message ?? "";
    final publishDate = announcement.publishAt != null
        ? DateFormat('dd MMM, yyyy HH:mm').format(
            DateTime.parse(announcement.publishAt!),
          )
        : "";
    final isImportant = announcement.priority?.toLowerCase() == 'high' || 
                        announcement.priority?.toLowerCase() == 'critical';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showAnnouncementDetail(context, title, message, publishDate, isImportant),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --------------------------- Icon Badge ---------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: linearGradient3,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 16),

            // --------------------------- Announcement Info ---------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: title,
                    fSize: 16,
                    fWeight: FontWeight.w700,
                    tColor: whiteColor,
                    maxLines: 1,
                    textoverflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  kText(
                    text: message,
                    fSize: 12,
                    tColor: Colors.grey.shade200,
                    maxLines: 1,
                    textoverflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  kText(
                    text: publishDate,
                    fSize: 11,
                    tColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            if (isImportant)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: kText(
                  text: TranslationKeys.important.tr,
                  fSize: 10,
                  tColor: whiteColor,
                  fWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(BuildContext context, String title, String body, String date, bool isImportant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            UIHelper.verticalSpaceSm20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: kText(
                      text: title,
                      fSize: 20.0,
                      fWeight: FontWeight.bold,
                      tColor: mainBlackcolor,
                    ),
                  ),
                  if (isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: kText(
                        text: TranslationKeys.important,
                        fSize: 12,
                        tColor: Colors.red,
                        fWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            UIHelper.verticalSpaceSm10,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  kText(
                    text: date,
                    fSize: 13.0,
                    tColor: Colors.grey,
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: kText(
                  text: body,
                  fSize: 15.0,
                  tColor: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: kText(
                    text: TranslationKeys.close,
                    fSize: 16,
                    tColor: Colors.white,
                    fWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
