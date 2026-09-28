import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/support_controller.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final SupportController _c = Get.put(SupportController());
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final sent = await _c.send(message: _messageController.text);
    if (sent) _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.contactSupport.tr,
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 16),
              if (!_c.isSupportEnabled)
                _supportBusyCard()
              else if (_c.limitReached && _c.hasLoadedOnce.value)
                _limitReachedCard()
              else
                _form(),
            ],
          );
        }),
      ),
    );
  }

  /// Gradient hero card: what this screen is for + messages left today.
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

  Widget _form() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(TranslationKeys.yourMessage.tr),
          const SizedBox(height: 8),
          _field(
            controller: _messageController,
            hint: TranslationKeys.writeYourMessageHere.tr,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: kText(
                  text:
                      _c.replyToEmail.isEmpty
                          ? TranslationKeys.weWillReplyByEmail.tr
                          : "${TranslationKeys.weWillReplyByEmail.tr} — ${_c.replyToEmail}",
                  fSize: 11.5,
                  tColor: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _c.isSending.value ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                disabledBackgroundColor: kPrimaryColor.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  _c.isSending.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          kText(
                            text: TranslationKeys.sendMessage.tr,
                            fSize: 15.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when Remote Config has support switched off.
  Widget _supportBusyCard() => _noticeCard(
    icon: Icons.schedule_rounded,
    color: const Color(0xffE08B00),
    title: TranslationKeys.supportUnavailable.tr,
    body: TranslationKeys.supportBusyTryLater.tr,
  );

  /// Shown once both of today's messages have been used.
  Widget _limitReachedCard() => _noticeCard(
    icon: Icons.mark_email_read_rounded,
    color: kPrimaryColor,
    title: TranslationKeys.dailyMessageLimitReached.tr,
    body: TranslationKeys.weWillReplyByEmail.tr,
  );

  Widget _noticeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return _card(
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          kText(
            text: title,
            fSize: 15.5,
            fWeight: FontWeight.w700,
            tColor: Colors.black87,
            textalign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          kText(
            text: body,
            fSize: 13.0,
            tColor: Colors.grey.shade600,
            textalign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── small shared pieces ────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
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
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
