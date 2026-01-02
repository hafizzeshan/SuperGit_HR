import 'package:flutter/material.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/ui_helpers.dart';

class PrescriptionCard extends StatelessWidget {
  final String patientName;
  final String patientMobile;
  final String patientAge;
  final List<String> status;
  final VoidCallback onTap;

  const PrescriptionCard({
    super.key,
    required this.patientName,
    required this.patientMobile,
    required this.patientAge,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red.shade100,
                child: Icon(Icons.person, color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),

            // 👤 Patient Name
            Row(
              children: [
                Icon(Icons.person, size: 14),
                SizedBox(width: 4),
                Expanded(
                  child: kText(
                    text: patientName,
                    fSize: 11.0,
                    fWeight: fontWeightBold,
                    textoverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpaceSm5,

            // 📱 Mobile Number
            Row(
              children: [
                Icon(Icons.phone, size: 14),
                SizedBox(width: 4),
                Expanded(
                  child: kText(
                    text: patientMobile,
                    fSize: 11.0,
                    tColor: const Color.fromARGB(255, 95, 93, 93),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpaceSm5,

            // 🎂 Age
            // Row(
            //   children: [
            //     Icon(Icons.cake, size: 14),
            //     SizedBox(width: 4),
            //     kText(text: patientAge, fSize: 12.0),
            //   ],
            // ),
            const SizedBox(height: 15),

            // 🔘 Status Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  status.map((s) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getStatusColor(s),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: kText(text: s, fSize: 7.0),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Ready':
        return Colors.green;
      case 'In Transit':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
