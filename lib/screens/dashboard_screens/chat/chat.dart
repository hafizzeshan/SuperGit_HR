import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/support_controller.dart';
import 'package:supergithr/screens/dashboard_screens/support/contact_support_screen.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/support_request_tile.dart';

/// Chat tab — shows the support requests the employee sent today and the way
/// to start a new one.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupportController _c = Get.put(SupportController());

  void _openSupport() => Get.to(() => const ContactSupportScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(
        title: TranslationKeys.support.tr,
        leadingWidget: const SizedBox(),
        actionWidget: IconButton(
          onPressed: _openSupport,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: kPrimaryColor, size: 22),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          // Only the very first read shows the shimmer; afterwards the list is
          // kept up to date in memory, so re-opening the tab costs no query.
          final isFirstLoad = !_c.hasLoadedOnce.value && _c.isLoading.value;

          return RefreshIndicator(
            onRefresh: () async {
              await _c.refreshSupportFlag();
              await _c.loadToday(force: true);
            },
            color: kPrimaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                context.listBottomInset(24),
              ),
              children: [
                _header(),
                const SizedBox(height: 18),
                if (isFirstLoad)
                  const SupportRequestShimmer()
                else if (_c.todaysRequests.isEmpty)
                  _emptyState()
                else ...[
                  _listHeader(),
                  const SizedBox(height: 12),
                  ..._c.todaysRequests.map(
                    (r) => SupportRequestTile(request: r),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xff00A3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(
                  text: TranslationKeys.supportMessage.tr,
                  fSize: 17.0,
                  fWeight: FontWeight.w700,
                  tColor: Colors.white,
                ),
                const SizedBox(height: 4),
                kText(
                  text:
                      _c.isSupportEnabled
                          ? "${_c.remainingToday} ${TranslationKeys.messagesLeftToday.tr}"
                          : TranslationKeys.supportUnavailable.tr,
                  fSize: 12.5,
                  tColor: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        kText(
          text: TranslationKeys.todaysMessages.tr,
          fSize: 15.0,
          fWeight: FontWeight.w700,
          tColor: Colors.black87,
        ),
        kText(
          text: "${_c.todaysRequests.length}/${SupportController.dailyLimit}",
          fSize: 12.5,
          fWeight: FontWeight.w600,
          tColor: Colors.grey.shade600,
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 14),
          kText(
            text: TranslationKeys.noMessagesToday.tr,
            fSize: 14.0,
            tColor: Colors.grey.shade500,
            textalign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _openSupport,
            icon: const Icon(Icons.support_agent, color: Colors.white),
            label: kText(
              text: TranslationKeys.contactSupport.tr,
              fSize: 14.0,
              fWeight: FontWeight.bold,
              tColor: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
