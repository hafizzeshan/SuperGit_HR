import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String? filePath;

  const DocumentViewerScreen({super.key, required this.filePath});

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final path = filePath ?? '';

    return Scaffold(
      appBar: appBarrWitoutAction(title: TranslationKeys.documentViewer.tr),
      backgroundColor: whiteColor,
      body: Center(
        child:
            path.isEmpty
                ? kText(
                  text: TranslationKeys.noDocumentAvailable.tr,
                  fSize: 16.0,
                  tColor: Colors.grey,
                )
                : Builder(
                  builder: (context) {
                    // Network / remote image
                    if (path.startsWith('http') && _isImage(path)) {
                      return InteractiveViewer(
                        child: Image.network(
                          path,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: kText(
                                  text: TranslationKeys.failedToLoadImage.tr,
                                  fSize: 14.0,
                                  tColor: Colors.red,
                                ),
                              ),
                        ),
                      );
                    }

                    // Local file image
                    if (!kIsWeb && File(path).existsSync() && _isImage(path)) {
                      return InteractiveViewer(
                        child: Image.file(File(path), fit: BoxFit.contain),
                      );
                    }

                    // Fallback: try to open in external browser (works for pdfs and other URLs)
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            size: 72,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(height: 16),
                          kText(
                            text: path.split('/').last,
                            textalign: TextAlign.center,
                            fSize: 14.0,
                            tColor: mainBlackcolor,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(path);
                              if (uri != null) {
                                if (!await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                )) {
                                  Get.snackbar(
                                    TranslationKeys.error.tr,
                                    TranslationKeys.couldNotOpenDocument.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  TranslationKeys.error.tr,
                                  TranslationKeys.invalidDocumentUrl.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.open_in_new),
                            label: kText(
                              text: TranslationKeys.openDocument.tr,
                              fSize: 14.0,
                              tColor: whiteColor,
                              fWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
