import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_animated_views.dart';

class AnnouncementBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    required String body,
    String? date,
    bool isImportant = true,
  }) {
    showCustomAnimatedBottomSheet(
      context: context,
      heightFactor: 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 30),

          // --- Premium Glassmorphic Header ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xff1A1A1A),
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: kText(
              text: title,
              fSize: 22.0,
              fWeight: FontWeight.bold,
              tColor: const Color(0xff1A1A1A),
              textalign: TextAlign.center,
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 30),

          // Content section with Glassmorphic Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Info Row
                    Row(
                      children: [
                        _infoBadge(
                          icon: Icons.access_time_rounded,
                          label: TranslationKeys.published.tr,
                          value: date ?? TranslationKeys.todayAtTime.tr,
                        ),
                        const Spacer(),
                        if (isImportant)
                          _statusBadge(
                            label: TranslationKeys.important.tr,
                            color: kPrimaryColor,
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title Label
                    kText(
                      text: TranslationKeys.details.tr,
                      fSize: 16.0,
                      fWeight: FontWeight.bold,
                      tColor: Colors.black87,
                    ),
                    const SizedBox(height: 12),

                    // Body content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: kText(
                        text: body,
                        fSize: 14.0,
                        tColor: Colors.grey.shade700,
                        fWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Additional Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: kText(
                              text: TranslationKeys.contactHrMessage.tr,
                              fSize: 12.0,
                              tColor: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Glassmorphic Footer
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  kText(
                    text: TranslationKeys.close.tr,
                    fSize: 16.0,
                    fWeight: FontWeight.w600,
                    tColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            kText(
              text: label,
              fSize: 11.0,
              tColor: Colors.grey.shade500,
              fWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 4),
        kText(
          text: value,
          fSize: 13.0,
          fWeight: FontWeight.w600,
          tColor: Colors.black87,
        ),
      ],
    );
  }

  static Widget _statusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          kText(
            text: label,
            fSize: 11.0,
            tColor: color,
            fWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
