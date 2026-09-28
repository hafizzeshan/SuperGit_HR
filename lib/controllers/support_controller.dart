import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/models/support_request_model.dart';
import 'package:supergithr/network/repository/support_repo/support_repo.dart';
import 'package:supergithr/services/force_update_service.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/utils.dart';

class SupportController extends GetxController {
  final SupportRepository _repo = SupportRepository();

  /// How many messages one employee may send per calendar day.
  static const int dailyLimit = 2;

  final isLoading = false.obs;
  final isSending = false.obs;
  final todaysRequests = <SupportRequestModel>[].obs;

  /// False while the day's requests are still loading, so the form doesn't
  /// flash into view for someone who has already used up their limit.
  final hasLoadedOnce = false.obs;

  /// Turned off from Remote Config when support is unavailable. Kept as an
  /// observable so flipping the switch updates an already-open screen.
  final supportEnabled = ForceUpdateService.supportEnabled.obs;

  bool get isSupportEnabled => supportEnabled.value;

  /// Pulls the latest flags so the switch works without an app restart.
  Future<void> refreshSupportFlag() async {
    await ForceUpdateService.refreshFeatureFlags();
    supportEnabled.value = ForceUpdateService.supportEnabled;
  }

  int get remainingToday =>
      (dailyLimit - todaysRequests.length).clamp(0, dailyLimit);

  bool get limitReached => todaysRequests.length >= dailyLimit;

  /// The form is only offered when support is on, the day's data has loaded
  /// and the employee still has messages left.
  bool get canSend => isSupportEnabled && hasLoadedOnce.value && !limitReached;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadToday();
    refreshSupportFlag();
  }

  Future<String> _employeeId() async {
    final fromModel = Get.find<ProfileController>().userModel.value.id;
    if (fromModel != null && fromModel.isNotEmpty) return fromModel;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id') ?? '';
  }

  /// Reads Firestore once per app session. Later changes are applied to the
  /// in-memory list, so opening the screen again costs no query. Pass
  /// [force] to genuinely re-read (pull-to-refresh).
  Future<void> loadToday({bool force = false}) async {
    if (hasLoadedOnce.value && !force) return;
    try {
      isLoading.value = true;
      final employeeId = await _employeeId();
      if (employeeId.isEmpty) {
        todaysRequests.clear();
        return;
      }
      todaysRequests.value = await _repo.fetchForDay(
        employeeId: employeeId,
        dayKey: _todayKey,
      );
    } catch (e) {
      print('⚠️ Failed to load support requests: $e');
      Utils.snackBar(TranslationKeys.failedToLoadRequests.tr, true);
    } finally {
      isLoading.value = false;
      hasLoadedOnce.value = true;
    }
  }

  /// The address support replies to, taken from the employee's profile.
  /// Empty when the profile has no email — the message still goes through,
  /// it just carries no reply-to.
  String get replyToEmail =>
      (Get.find<ProfileController>().userModel.value.email ?? '').trim();

  /// Returns true when the message was stored and queued for delivery.
  Future<bool> send({required String message}) async {
    final trimmedMessage = message.trim();

    // Hiding the form is not enough — the switch has to be enforced here too,
    // and against a freshly fetched value, not one cached since app launch.
    await refreshSupportFlag();
    if (!isSupportEnabled) {
      Utils.snackBar(TranslationKeys.supportBusyTryLater.tr, true);
      return false;
    }
    if (trimmedMessage.isEmpty) {
      Utils.snackBar(TranslationKeys.pleaseEnterYourMessage.tr, true);
      return false;
    }
    if (limitReached) {
      Utils.snackBar(TranslationKeys.dailyMessageLimitReached.tr, true);
      return false;
    }

    try {
      isSending.value = true;
      final user = Get.find<ProfileController>().userModel.value;
      final employeeId = await _employeeId();
      final name = "${user.firstNameEn ?? ''} ${user.lastNameEn ?? ''}".trim();
      final packageInfo = await PackageInfo.fromPlatform();

      final request = SupportRequestModel(
        id: '',
        employeeId: employeeId,
        employeeCode: user.employeeCode ?? '',
        employeeName: name,
        email: replyToEmail,
        phone: user.mobileNumber ?? '',
        message: trimmedMessage,
        dayKey: _todayKey,
      );

      final id = await _repo.send(
        request: request,
        appVersion: '${packageInfo.version} (${packageInfo.buildNumber})',
      );

      // Show it straight away rather than re-reading the whole day.
      todaysRequests.insert(
        0,
        SupportRequestModel(
          id: id,
          employeeId: request.employeeId,
          employeeCode: request.employeeCode,
          employeeName: request.employeeName,
          email: request.email,
          phone: request.phone,
          message: request.message,
          dayKey: request.dayKey,
          createdAt: DateTime.now(),
        ),
      );
      Utils.snackBar(TranslationKeys.messageSentToSupport.tr, false);
      return true;
    } catch (e) {
      print('⚠️ Failed to send support request: $e');
      Utils.snackBar(TranslationKeys.failedToSendMessage.tr, true);
      return false;
    } finally {
      isSending.value = false;
    }
  }
}
