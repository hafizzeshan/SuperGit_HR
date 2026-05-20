import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

class ForceUpdateService {
  /// 🔧 MANUAL SWITCH — set to `false` to ignore Firebase Remote Config
  /// entirely (base_url override + force update) and use the local code
  /// values from [AppURL.defaultBaseUrl]. Change here and rebuild.
  static const bool applyRemoteConfig = true;

  static final ForceUpdateService _instance = ForceUpdateService._internal();
  factory ForceUpdateService() => _instance;
  ForceUpdateService._internal();

  /// Checks Firebase Remote Config and returns update info if a force update is needed.
  /// Returns null if no update is required.
  Future<ForceUpdateInfo?> checkForUpdate() async {
    try {
      // Manual switch: when off, skip Remote Config entirely and use the
      // local code base URL (no force update either).
      if (!applyRemoteConfig) {
        AppURL.baseUrl = AppURL.defaultBaseUrl;
        ApiNetworkService().dio.options.baseUrl = AppURL.baseUrl;
        print("⏭️ Remote Config disabled (manual) — using local base URL: "
            "${AppURL.baseUrl}");
        return null;
      }

      final remoteConfig = FirebaseRemoteConfig.instance;

      // Set defaults
      await remoteConfig.setDefaults({
        'min_version_android': '1.0.0',
        'min_version_ios': '1.0.0',
        'min_build_number_android': 1,
        'min_build_number_ios': 1,
        'force_update': false,
        'update_message':
            'A new version is available. Please update to continue.',
        'play_store_url': '',
        'app_store_url': '',
        'base_url': AppURL.baseUrl,
      });

      // Fetch with short cache for quick updates
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      // Print all Remote Config values
      print("╔══════════════════════════════════════════════════════");
      print("║ 🔥 FIREBASE REMOTE CONFIG VALUES");
      print("╠══════════════════════════════════════════════════════");
      print(
        "║ force_update:              ${remoteConfig.getString('force_update')}",
      );
      print(
        "║ min_version_android:       ${remoteConfig.getString('min_version_android')}",
      );
      print(
        "║ min_version_ios:           ${remoteConfig.getString('min_version_ios')}",
      );
      print(
        "║ min_build_number_android:  ${remoteConfig.getString('min_build_number_android')}",
      );
      print(
        "║ min_build_number_ios:      ${remoteConfig.getString('min_build_number_ios')}",
      );
      print(
        "║ update_message:            ${remoteConfig.getString('update_message')}",
      );
      print(
        "║ play_store_url:            ${remoteConfig.getString('play_store_url')}",
      );
      print(
        "║ app_store_url:             ${remoteConfig.getString('app_store_url')}",
      );
      print(
        "║ base_url:                  ${remoteConfig.getString('base_url')}",
      );
      print("╚══════════════════════════════════════════════════════");

      // ✅ Apply base URL from Remote Config
      final String remoteBaseUrl = remoteConfig.getString('base_url');
      if (remoteBaseUrl.isNotEmpty) {
        AppURL.updateBaseUrl(remoteBaseUrl);
        ApiNetworkService().dio.options.baseUrl = AppURL.baseUrl;
      }

      // Handle force_update as both Boolean and String type
      final String forceUpdateStr = remoteConfig.getString('force_update');
      final bool forceUpdate =
          forceUpdateStr.toLowerCase() == 'true' ||
          remoteConfig.getBool('force_update');
      if (!forceUpdate) {
        print("✅ Force update is OFF — skipping update check");
        return null;
      }

      final String minVersion =
          Platform.isAndroid
              ? remoteConfig.getString('min_version_android')
              : remoteConfig.getString('min_version_ios');

      // Handle build number as both Number and String type
      final String minBuildStr =
          Platform.isAndroid
              ? remoteConfig.getString('min_build_number_android')
              : remoteConfig.getString('min_build_number_ios');
      final int minBuildNumber =
          int.tryParse(minBuildStr) ??
          remoteConfig.getInt(
            Platform.isAndroid
                ? 'min_build_number_android'
                : 'min_build_number_ios',
          );

      final String updateMessage = remoteConfig.getString('update_message');
      final String storeUrl =
          Platform.isAndroid
              ? remoteConfig.getString('play_store_url')
              : remoteConfig.getString('app_store_url');

      // Get current app version and build number
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      print("╔══════════════════════════════════════════════════════");
      print("║ 📱 CURRENT APP INFO");
      print("╠══════════════════════════════════════════════════════");
      print("║ Platform:        ${Platform.isAndroid ? 'Android' : 'iOS'}");
      print("║ App Version:     $currentVersion");
      print("║ Build Number:    $currentBuildNumber");
      print("║ Min Version:     $minVersion");
      print("║ Min Build:       $minBuildNumber");
      print("╚══════════════════════════════════════════════════════");

      // Check if update is needed (version OR build number)
      final bool needsUpdate = _needsUpdate(
        currentVersion,
        minVersion,
        currentBuildNumber,
        minBuildNumber,
      );

      print(
        needsUpdate
            ? "🚨 UPDATE REQUIRED — current app is outdated"
            : "✅ App is up to date — no update needed",
      );

      if (needsUpdate) {
        return ForceUpdateInfo(
          currentVersion: currentVersion,
          minVersion: minVersion,
          currentBuildNumber: currentBuildNumber,
          minBuildNumber: minBuildNumber,
          updateMessage: updateMessage,
          storeUrl: storeUrl,
        );
      }

      return null;
    } catch (e) {
      print("⚠️ Force update check failed: $e");
      // Don't block the app if remote config fails
      return null;
    }
  }

  /// Returns true if the app needs an update.
  /// First compares version name, then build number if versions are equal.
  bool _needsUpdate(
    String currentVersion,
    String minVersion,
    int currentBuildNumber,
    int minBuildNumber,
  ) {
    final currentParts =
        currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final minimumParts =
        minVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad shorter list with zeros
    while (currentParts.length < 3) currentParts.add(0);
    while (minimumParts.length < 3) minimumParts.add(0);

    // Compare version name first
    for (int i = 0; i < 3; i++) {
      if (currentParts[i] < minimumParts[i]) return true;
      if (currentParts[i] > minimumParts[i]) return false;
    }

    // Versions are equal — compare build number
    return currentBuildNumber < minBuildNumber;
  }
}

class ForceUpdateInfo {
  final String currentVersion;
  final String minVersion;
  final int currentBuildNumber;
  final int minBuildNumber;
  final String updateMessage;
  final String storeUrl;

  ForceUpdateInfo({
    required this.currentVersion,
    required this.minVersion,
    required this.currentBuildNumber,
    required this.minBuildNumber,
    required this.updateMessage,
    required this.storeUrl,
  });
}
