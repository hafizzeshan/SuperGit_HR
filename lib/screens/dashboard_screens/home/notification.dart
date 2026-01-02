import 'package:flutter/material.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      // {
      //   "title": "Leave Approved",
      //   "message": "Your vacation leave request has been approved.",
      //   "icon": Icons.check_circle_outline,
      //   "time": "10 mins ago",
      //   "color": Colors.green,
      // },
      // {
      //   "title": "New Announcement",
      //   "message": "Quarterly meeting scheduled for May 15.",
      //   "icon": Icons.campaign_outlined,
      //   "time": "2 hrs ago",
      //   "color": Colors.blue,
      // },
      // {
      //   "title": "Payroll Processed",
      //   "message": "Your April payslip is now available.",
      //   "icon": Icons.payments_outlined,
      //   "time": "Yesterday",
      //   "color": Colors.amber,
      // },
      // {
      //   "title": "Attendance Alert",
      //   "message": "You missed check-out on May 1.",
      //   "icon": Icons.access_time,
      //   "time": "2 days ago",
      //   "color": Colors.redAccent,
      // },
    ];

    return Scaffold(
      appBar: appBarrWitoutAction(title: "Notifications"),
      backgroundColor: Colors.white,
      body:
          notifications.isEmpty
              ? Center(
                child: kText(
                  text: "No notifications available",
                  fSize: 14,
                  tColor: Colors.grey,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: item["color"].withOpacity(0.15),
                          child: Icon(
                            item["icon"],
                            color: item["color"],
                            size: 22,
                          ),
                        ),
                        UIHelper.horizontalSpaceSm10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kText(
                                text: item["title"],
                                fWeight: FontWeight.bold,
                                fSize: 12.5,
                              ),
                              UIHelper.verticalSpaceSm5,
                              kText(
                                text: item["message"],
                                fSize: 11.0,
                                tColor: Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ),
                        UIHelper.horizontalSpaceSm10,
                        kText(
                          text: item["time"],
                          fSize: 11.5,
                          tColor: Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
