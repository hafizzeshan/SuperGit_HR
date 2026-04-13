import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supergithr/services/force_update_service.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class ForceUpdateDialog {
  /// Shows a non-dismissable force update dialog
  static void show(BuildContext context, ForceUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App icon
                Container(
                  height: 80,
                  width: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(AppAssets.logo),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Update Required",
                  style: textStyleMontserratBold(
                    color: appblueColor,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  info.updateMessage,
                  textAlign: TextAlign.center,
                  style: textStyleMontserratMiddle(
                    color: Colors.grey.shade600,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 8),

                // Version info
                Text(
                  "Current: v${info.currentVersion} (${info.currentBuildNumber})  →  Required: v${info.minVersion} (${info.minBuildNumber})",
                  textAlign: TextAlign.center,
                  style: textStyleMontserratRegular(
                    color: Colors.grey.shade500,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 24),

                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _openStore(info.storeUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Update Now",
                      style: textStyleMontserratBold(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _openStore(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
