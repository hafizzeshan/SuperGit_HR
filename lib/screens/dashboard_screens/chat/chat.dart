import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Use RxList to observe changes
  final RxList<Map<String, String>> chatList = <Map<String, String>>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarrWitoutAction(
        title: TranslationKeys.chat,
        leadingWidget: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: TranslationKeys.search.tr,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            UIHelper.verticalSpaceSm15,

            // Filter Chips
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     _chip(TranslationKeys.all.tr, true),
            //     UIHelper.horizontalSpaceSm10,
            //     _chip(TranslationKeys.unread.tr, false),
            //     UIHelper.horizontalSpaceSm10,
            //     _chip(TranslationKeys.groups.tr, false),
            //   ],
            // ),

            UIHelper.verticalSpaceSm15,

            // Chat List or Empty State
            Expanded(
              child: Obx(() {
                if (chatList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        UIHelper.verticalSpaceSm15,
                        kText(
                          text: TranslationKeys.noChatsAvailable.tr,
                          fSize: 16,
                          tColor: Colors.grey,
                        ),
                        UIHelper.verticalSpaceSm20,
                        ElevatedButton.icon(
                          onPressed: () {
                            // Simulate starting a chat with admin
                            // chatList.add({
                            //   "initial": "AD",
                            //   "name": TranslationKeys.admin,
                            //   "message": TranslationKeys.supportMessage,
                            //   "time": TranslationKeys.justNow,
                            // });
                          },
                          icon: const Icon(Icons.support_agent, color: Colors.white),
                          label: kText(
                            text: TranslationKeys.contactSupport,
                            fSize: 14,
                            tColor: Colors.white,
                            fWeight: FontWeight.bold,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: chatList.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final chat = chatList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(5.0),
                      onTap: () {
                        // Navigate to chat detail
                      },
                      leading: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          chat["initial"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: kText(
                        text: chat["name"]!,
                        fSize: 14.5,
                        fWeight: FontWeight.bold,
                      ),
                      subtitle: kText(text: chat["message"]!, fSize: 13.0),
                      trailing: kText(
                        text: chat["time"]!,
                        fSize: 12.0,
                        tColor: Colors.grey,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 13,
      ),
      backgroundColor: isSelected ? kPrimaryColor : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
