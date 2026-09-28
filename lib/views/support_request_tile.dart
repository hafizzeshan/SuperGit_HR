import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/models/support_request_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/customText.dart';

/// One sent support request, as shown on the Chat tab.
class SupportRequestTile extends StatelessWidget {
  final SupportRequestModel request;

  const SupportRequestTile({super.key, required this.request});

  static const Color _sentGreen = Color(0xff2E9E5B);

  @override
  Widget build(BuildContext context) {
    final sentAt = request.createdAt;
    final time = sentAt == null ? '' : DateFormat('hh:mm a').format(sentAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _sentGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: _sentGreen,
                    ),
                    const SizedBox(width: 5),
                    kText(
                      text: TranslationKeys.sent.tr,
                      fSize: 11.0,
                      fWeight: FontWeight.w600,
                      tColor: _sentGreen,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (time.isNotEmpty)
                kText(text: time, fSize: 11.5, tColor: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 12),
          kText(
            text: request.message,
            fSize: 13.5,
            tColor: Colors.black87,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}

/// Placeholder rows shown while the day's requests are being read.
class SupportRequestShimmer extends StatelessWidget {
  final int itemCount;

  const SupportRequestShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          itemCount,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    bar(64, 20),
                    const Spacer(),
                    bar(52, 12),
                  ],
                ),
                const SizedBox(height: 14),
                bar(double.infinity, 12),
                const SizedBox(height: 8),
                bar(180, 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
