import 'package:flutter/material.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final List<Map<String, String>> chatList = [
    {
      "initial": "HM",
      "name": "Hafiz Zeshan",
      "message": "This is a new chat",
      "time": "4:11 PM",
    },
    {
      "initial": "👥",
      "name": "Team chat",
      "message": "This is a new chat",
      "time": "08/03/2023",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarrWitoutAction(title: "Chat", leadingWidget: SizedBox()),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                // suffixIcon: const Icon(Icons.delete_outline),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _chip("All", true),
                UIHelper.horizontalSpaceSm10,
                _chip("Unread", false),
                UIHelper.horizontalSpaceSm10,
                _chip("Groups", false),
              ],
            ),

            UIHelper.verticalSpaceSm15,

            // Chat List
            Expanded(
              child: ListView.separated(
                itemCount: chatList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.all(5.0),
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
              ),
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
