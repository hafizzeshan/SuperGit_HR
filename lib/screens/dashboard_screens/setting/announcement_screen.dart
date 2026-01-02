import 'package:flutter/material.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> announcements = [];

    return Scaffold(
      appBar: appBarrWitAction(title: "Announcements"),
      backgroundColor: Colors.grey.shade100,
      body:
          announcements.isEmpty
              ? Center(
                child: kText(
                  text: "No announcements available",
                  fSize: 16.0,
                  tColor: Colors.grey,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => UIHelper.verticalSpaceSm10,
                itemBuilder: (_, index) {
                  final item = announcements[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(
                          text: item['title'] ?? '',
                          fSize: 16.0,
                          fWeight: FontWeight.bold,
                          tColor: kPrimaryColor,
                        ),
                        UIHelper.verticalSpaceSm5,
                        kText(
                          text: item['content'] ?? '',
                          fSize: 14.0,
                          tColor: Colors.black87,
                        ),
                        UIHelper.verticalSpaceSm10,
                        Align(
                          alignment: Alignment.bottomRight,
                          child: kText(
                            text: item['date'] ?? '',
                            fSize: 12.0,
                            tColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
