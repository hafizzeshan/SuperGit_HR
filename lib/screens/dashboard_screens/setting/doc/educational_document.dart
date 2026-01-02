import 'package:flutter/material.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class EducationalDocumentsScreen extends StatelessWidget {
  const EducationalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> documents = [
      {
        'name': 'Matric Certificate',
        'institution': 'Punjab Board',
        'degree': 'Secondary School Certificate',
        'field': 'Science',
        'year': '2012',
        'uploadDate': '2021-05-10',
        'status': 'Verified',
        'remarks': 'Verified by HR',
      },
      {
        'name': 'Bachelor Degree',
        'institution': 'Punjab University',
        'degree': 'Bachelor of Science',
        'field': 'Computer Science',
        'year': '2016',
        'uploadDate': '2022-01-15',
        'status': 'Pending',
        'remarks': 'Awaiting verification',
      },
    ];

    return Scaffold(
      appBar: appBarrWitAction(title: "Educational Documents"),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                kText(text: doc['name'], fSize: 16.0, fWeight: FontWeight.bold),
                UIHelper.verticalSpaceSm10,
                _buildRow('Institution', doc['institution']),
                _buildRow('Degree', doc['degree']),
                _buildRow('Field of Study', doc['field']),
                _buildRow('Passing Year', doc['year']),
                _buildRow('Upload Date', doc['uploadDate']),
                _buildRow('Remarks', doc['remarks']),
                UIHelper.verticalSpaceSm10,
                Row(
                  children: [
                    _statusChip(doc['status']),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View Document"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: kText(
              text: "$title:",
              fSize: 13.0,
              fWeight: FontWeight.w500,
              tColor: Colors.grey.shade700,
            ),
          ),
          Expanded(
            flex: 3,
            child: kText(text: value, fSize: 13.0, tColor: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color =
        status == "Verified"
            ? Colors.green
            : status == "Pending"
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: kText(
        text: status,
        fSize: 12.0,
        tColor: color,
        fWeight: FontWeight.w600,
      ),
    );
  }
}
