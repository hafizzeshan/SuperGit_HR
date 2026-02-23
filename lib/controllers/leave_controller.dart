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
      final pageToFetch = currentPage.value;
      log("📡 Fetching Leave Types: Page $pageToFetch (PageSize: ${pageSize.value})");

      final response = await _repo.getLeaveTypes(
        page: pageToFetch,
        pageSize: pageSize.value,
      );

      log("📥 Leave Types Response received for Page $pageToFetch");

      if (response != null && response["data"] != null) {
        final List rawData = response["data"];
        final types = rawData.map((e) => LeaveTypeModel.fromJson(e)).toList();

        if (pageToFetch == 1) {
          leaveTypes.assignAll(types);
        } else {
          // Prevent duplicates
          final existingIds = leaveTypes.map((e) => e.id).toSet();
          final newItems = types.where((item) => !existingIds.contains(item.id)).toList();
          leaveTypes.addAll(newItems);
        }

        // Robust parsing of pagination metadata
        final total = int.tryParse(response["total"]?.toString() ?? "0") ?? 0;
        final totalPages = int.tryParse(response["total_pages"]?.toString() ?? "1") ?? 1;
        final serverPage = int.tryParse(response["page"]?.toString() ?? pageToFetch.toString()) ?? pageToFetch;

        this.totalPages.value = totalPages;
        this.totalItems.value = total;
        this.currentPage.value = serverPage;

        hasMore.value = currentPage.value < this.totalPages.value;

        log(
          "✅ Leave Types updated: CurrentPage: ${currentPage.value}, TotalPages: ${this.totalPages.value}, TotalItems: ${this.totalItems.value}, HasMore: ${hasMore.value}",
        );
      } else {
        log("⚠️ No data in leave types response");
        hasMore.value = false;
      }
    } catch (e) {
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

    if (currentPage.value >= totalPages.value) {
      hasMore.value = false;
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
  Future<void> submitLeaveRequest() async {
    print("🚀 submitLeaveRequest() called");
    log("🚀 submitLeaveRequest() called");
    final startDate = startDateController.text.trim();
    final endDate = endDateController.text.trim();
    final totalDays = totalDaysController.text.trim();
    final reason = reasonController.text.trim();
    if (selectedLeaveTypeId.value == null ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        totalDays.isEmpty ||
        reason.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      Utils.snackBar(
        TranslationKeys.pleaseFillAllRequiredFields.tr,
        true,
      );
      return;
    }

    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        FocusManager.instance.primaryFocus?.unfocus();
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        isSubmitting.value = false;
        return;
      }

      final data = {
        "employee_id": employeeId,
        "leave_type_id": selectedLeaveTypeId.value,
        "start_date": startDate,
        "end_date": endDate,
        "total_days": totalDays, // Sending as string to match Postman spec
        "reason": reason,
      };

      // Always use FormData (multipart/form-data) — the backend expects it
      final formData = dio.FormData.fromMap(data);

      // Add file if attached
      if (attachedFile.value != null && attachedFile.value!.path != null) {
        formData.files.add(
          MapEntry(
            "files",
            await dio.MultipartFile.fromFile(
              attachedFile.value!.path!,
              filename: attachedFile.value!.name,
            ),
          ),
        );
      }

      final response = await _repo.createLeaveRequest(
        data: formData,
        isMultipart: true,
      );
      isSubmitting.value = false;

      if (response != null && response["data"] != null) {
        final leaveRequest = LeaveRequestModel.fromJson(response["data"]);

        // Add the new leave request to the top of the history list
        leaveHistory.insert(0, leaveRequest);
        historyTotalItems.value++;

        final successMessage =
            response["message"] ??
            TranslationKeys.leaveRequestSubmittedSuccessfully.tr;

        Utils.snackBar(successMessage, false);
        clearForm();
        log("✅ Leave Request: ${leaveRequest.toJson()}");

        // Navigate back to requests screen safely
        Navigator.of(Get.context!).pop();
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
      log("🔄 Refreshing Leave History (Clearing list)");
      historyCurrentPage.value = 1;
      leaveHistory.clear();
      hasMoreHistory.value = true;
    }

    // Set loading flags
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

      final pageToFetch = historyCurrentPage.value;
      log("📡 API REQUEST => Leave History | Page: $pageToFetch | PageSize: ${historyPageSize.value}");

      final response = await _repo.getEmployeeLeaveHistory(
        employeeId,
        page: pageToFetch,
        pageSize: historyPageSize.value,
      );

      log("📥 API RESPONSE => Status: SUCCESS for Page $pageToFetch");

      if (response != null && (response["data"] != null || response is List)) {
        // Handle cases where response might be the list itself or contains a "data" key
        final List rawData = response["data"] ?? (response is List ? response : []);
        final history = rawData.map((e) => LeaveRequestModel.fromJson(e)).toList();

        if (pageToFetch == 1) {
          leaveHistory.assignAll(history);
          log("📄 Initial load: ${history.length} items");
        } else {
          // Prevent duplicates by checking ID
          final existingIds = leaveHistory.map((e) => e.id).toSet();
          final newUniqueItems = history.where((item) => 
            item.id != null && !existingIds.contains(item.id)
          ).toList();
          
          if (newUniqueItems.isNotEmpty) {
            leaveHistory.addAll(newUniqueItems);
            log("➕ Appended ${newUniqueItems.length} new items (Total: ${leaveHistory.length})");
          } else {
            log("⚠️ No new unique items found on Page $pageToFetch - API might be repeating data");
          }
        }

        // Resilient metadata parsing for various common API naming conventions
        final total = int.tryParse(
          (response["total"] ?? response["total_items"] ?? response["count"] ?? "0").toString()
        ) ?? 0;
        
        final totalPages = int.tryParse(
          (response["total_pages"] ?? response["total_pages_count"] ?? response["last_page"] ?? response["totalPages"] ?? "1").toString()
        ) ?? 1;
        
        final serverPage = int.tryParse(
          (response["page"] ?? response["current_page"] ?? pageToFetch.toString()).toString()
        ) ?? pageToFetch;

        historyTotalPages.value = totalPages;
        historyTotalItems.value = total;
        historyCurrentPage.value = serverPage;

        // Final check for more data
        hasMoreHistory.value = historyCurrentPage.value < historyTotalPages.value;

        log(
          "📜 META SYNC => Page: ${historyCurrentPage.value}/$totalPages | Total: $total | hasMore: ${hasMoreHistory.value}",
        );
      } else {
        log("⚠️ API returned empty or invalid structure for history");
        hasMoreHistory.value = false;
      }
    } catch (e, st) {
      log("❌ PAGINATION EXCEPTION: $e", stackTrace: st);
    } finally {
      isHistoryLoading.value = false;
      isLoadingMoreHistory.value = false;
    }
  }

  /// ✅ Load More Leave History
  Future<void> loadMoreLeaveHistory() async {
    // Check if we are already loading or if there's no more data
    if (!hasMoreHistory.value) {
      log("⏹️ loadMore skipped: No more history (hasMore=false)");
      return;
    }
    
    if (isLoadingMoreHistory.value || isHistoryLoading.value) {
      log("⏳ loadMore skipped: Already loading (Wait for current fetch)");
      return;
    }

    if (historyCurrentPage.value >= historyTotalPages.value) {
      log("⏹️ loadMore skipped: Current page (${historyCurrentPage.value}) is already at Total pages (${historyTotalPages.value})");
      hasMoreHistory.value = false;
      return;
    }

    log("🔼 PAGINATION => Advancing to next page: ${historyCurrentPage.value + 1}");
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
