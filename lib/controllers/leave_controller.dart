import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/leave_request_model.dart';
import 'package:supergithr/models/leave_type_model.dart';
import 'package:supergithr/network/repository/attendance_repo/leave_repo.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';

class LeaveController extends GetxController {
  final LeaveRepository _repo = LeaveRepository();

  /// Observables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isHistoryLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingMoreHistory = false.obs;

  var leaveTypes = <LeaveTypeModel>[].obs;
  var leaveHistory = <LeaveRequestModel>[].obs;
  var selectedLeaveTypeId = RxnString();
  final attachedFile = Rxn<PlatformFile>();

  /// Pagination variables for leave types
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var pageSize = 100.obs;
  var hasMore = true.obs;

  /// Pagination variables for leave history
  var historyCurrentPage = 1.obs;
  var historyTotalPages = 1.obs;
  var historyTotalItems = 0.obs;
  var historyPageSize = 10.obs;
  var hasMoreHistory = true.obs;

  /// Form controllers
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final totalDaysController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void onInit() {
    log("✅ LeaveController initialized");
    super.onInit();
  }

  /// ✅ Fetch Leave Types (Initial Load)
  Future<void> fetchLeaveTypes({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      leaveTypes.clear();
      hasMore.value = true;
    }

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await _repo.getLeaveTypes(
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (response != null && response["data"] != null) {
        final types =
            (response["data"] as List)
                .map((e) => LeaveTypeModel.fromJson(e))
                .toList();

        if (currentPage.value == 1) {
          leaveTypes.assignAll(types);
        } else {
          leaveTypes.addAll(types);
        }

        // Update pagination metadata
        totalPages.value = response["total_pages"] ?? 1;
        totalItems.value = response["total"] ?? 0;
        hasMore.value = currentPage.value < totalPages.value;

        log(
          "✅ Leave Types fetched: Page ${currentPage.value}/${totalPages.value}, Items: ${types.length}, Total: ${totalItems.value}",
        );
      } else {
        log("⚠️ Failed to load leave types - response was null");
        hasMore.value = false;
      }
    } catch (e) {
      // Don't show error message - let the 401 interceptor handle session expiry
      log("❌ Error loading leave types: $e");
      hasMore.value = false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// ✅ Load More Leave Types
  Future<void> loadMoreLeaveTypes() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }

    currentPage.value++;
    await fetchLeaveTypes();
  }

  Future<void> refreshLeaveTypes() async {
    await fetchLeaveTypes(refresh: true);
  }

  /// ✅ Pick Document
  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        attachedFile.value = result.files.first;
        log("✅ File Selected: ${attachedFile.value!.name}");
      } else {
        log("⚠️ File selection canceled");
      }
    } catch (e) {
      log("❌ Error picking file: $e");
      Utils.snackBar(TranslationKeys.errorPickingFile.tr, true);
    }
  }

  /// ✅ Clear Selected File
  void clearAttachedFile() {
    attachedFile.value = null;
  }

  /// ✅ Submit Leave Request
  Future<void> submitLeaveRequest(BuildContext context) async {
    final startDate = startDateController.text.trim();
    final endDate = endDateController.text.trim();
    final totalDays = totalDaysController.text.trim();
    final reason = reasonController.text.trim();

    if (selectedLeaveTypeId.value == null ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        totalDays.isEmpty ||
        reason.isEmpty) {
      log(
        "⚠️ Validation failed: Type: ${selectedLeaveTypeId.value}, Start: $startDate, End: $endDate, Days: $totalDays, Reason: $reason",
      );
      Utils.snackBar(TranslationKeys.pleaseFillAllRequiredFields.tr, true, context: context);
      return;
    }

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        isSubmitting.value = false;
        return;
      }

      final data = {
        "employee_id": employeeId,
        "leave_type_id": selectedLeaveTypeId.value,
        "start_date": startDate,
        "end_date": endDate,
        "total_days": int.tryParse(totalDays) ?? 1,
        "reason": reason,
      };

      dynamic requestData;
      bool isMultipart = false;

      if (attachedFile.value != null) {
        isMultipart = true;

        // Create FormData
        final formData = dio.FormData.fromMap(data);

        // Add file
        if (attachedFile.value!.path != null) {
          formData.files.add(
            MapEntry(
              "document",
              await dio.MultipartFile.fromFile(
                attachedFile.value!.path!,
                filename: attachedFile.value!.name,
              ),
            ),
          );
        }

        requestData = formData;
      } else {
        requestData = data;
      }

      final response = await _repo.createLeaveRequest(
        data: requestData,
        isMultipart: isMultipart,
      );
      isSubmitting.value = false;

      if (response != null && response["data"] != null) {
        final leaveRequest = LeaveRequestModel.fromJson(response["data"]);

        // Add the new leave request to the top of the history list
        leaveHistory.insert(0, leaveRequest);
        historyTotalItems.value++;

        Utils.snackBar(TranslationKeys.leaveRequestSubmittedSuccessfully.tr, false);
        clearForm();
        log("✅ Leave Request: ${leaveRequest.toJson()}");

        // Navigate back to requests screen
        Get.back();
      } else {
        // Error handled in repository
      }
    } catch (e) {
      isSubmitting.value = false;
      log("❌ Error submitting leave request: $e");

      String errorMessage = "Error submitting leave request";

      if (e is dio.DioException) {
        if (e.response != null && e.response!.data != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (data is Map && data['error'] != null) {
            errorMessage = data['error'].toString();
          } else {
            errorMessage =
                e.response?.statusMessage ??
                "Server Error: ${e.response?.statusCode}";
          }
        } else {
          errorMessage = e.message ?? "Network Error";
        }
      } else {
        errorMessage = e.toString();
      }

      Utils.snackBar(errorMessage, true);
    }
  }

  /// ✅ Fetch Employee Leave History with Pagination
  Future<void> getEmployeeLeaveHistory({bool refresh = false}) async {
    if (refresh) {
      historyCurrentPage.value = 1;
      leaveHistory.clear();
      hasMoreHistory.value = true;
    }

    if (historyCurrentPage.value == 1) {
      isHistoryLoading.value = true;
    } else {
      isLoadingMoreHistory.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        return;
      }

      final response = await _repo.getEmployeeLeaveHistory(
        employeeId,
        page: historyCurrentPage.value,
        pageSize: historyPageSize.value,
      );

      if (response != null && response["data"] != null) {
        final history =
            (response["data"] as List)
                .map((e) => LeaveRequestModel.fromJson(e))
                .toList();

        if (historyCurrentPage.value == 1) {
          leaveHistory.assignAll(history);
        } else {
          leaveHistory.addAll(history);
        }

        // Update pagination metadata
        historyTotalPages.value = response["total_pages"] ?? 1;
        historyTotalItems.value = response["total"] ?? 0;
        hasMoreHistory.value =
            historyCurrentPage.value < historyTotalPages.value;

        log(
          "✅ Leave history fetched: Page ${historyCurrentPage.value}/${historyTotalPages.value}, Items: ${history.length}, Total: ${historyTotalItems.value}",
        );
      } else {
        hasMoreHistory.value = false;
      }
    } catch (e, st) {
      log("❌ Error fetching leave history: $e", stackTrace: st);
      hasMoreHistory.value = false;
    } finally {
      isHistoryLoading.value = false;
      isLoadingMoreHistory.value = false;
    }
  }

  /// ✅ Load More Leave History
  Future<void> loadMoreLeaveHistory() async {
    if (!hasMoreHistory.value ||
        isLoadingMoreHistory.value ||
        isHistoryLoading.value) {
      return;
    }

    historyCurrentPage.value++;
    await getEmployeeLeaveHistory();
  }

  /// ✅ Refresh Leave History
  Future<void> refreshLeaveHistory() async {
    await getEmployeeLeaveHistory(refresh: true);
  }

  /// ✅ Clear Form Fields
  void clearForm() {
    startDateController.clear();
    endDateController.clear();
    totalDaysController.clear();
    reasonController.clear();
    selectedLeaveTypeId.value = null;
    attachedFile.value = null;
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    totalDaysController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
