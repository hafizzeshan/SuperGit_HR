import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/air_ticket_models.dart';
import 'package:supergithr/network/repository/air_ticket_repo/air_ticket_repo.dart';

class AirTicketController extends GetxController {
  final AirTicketRepository _repo = AirTicketRepository();

  // Entitlement state
  final isLoadingEntitlement = false.obs;
  final Rxn<AirTicketEntitlement> entitlement = Rxn<AirTicketEntitlement>();
  final entitlementHistory = <AirTicketEntitlement>[].obs;

  // Requests list state
  final isLoadingRequests = false.obs;
  final requests = <AirTicketRequest>[].obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final statusFilter = ''.obs;

  // Request details state
  final isLoadingDetails = false.obs;
  final Rxn<AirTicketRequestDetails> selectedRequest =
      Rxn<AirTicketRequestDetails>();

  // Mutations
  final isSubmitting = false.obs;
  final isCancelling = false.obs;

  Future<String> _employeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id') ?? '';
  }

  /// Load current-year entitlement for the logged-in employee.
  Future<void> fetchEntitlement({int? year}) async {
    try {
      isLoadingEntitlement.value = true;
      final empId = await _employeeId();
      if (empId.isEmpty) return;
      final data = await _repo.getEntitlement(employeeId: empId, year: year);
      if (data != null) entitlement.value = AirTicketEntitlement.fromMap(data);
    } catch (e, st) {
      log("❌ fetchEntitlement: $e", stackTrace: st);
    } finally {
      isLoadingEntitlement.value = false;
    }
  }

  /// Load full entitlement history across years.
  Future<void> fetchAllEntitlements() async {
    try {
      isLoadingEntitlement.value = true;
      final empId = await _employeeId();
      if (empId.isEmpty) return;
      final list = await _repo.getAllEntitlements(empId);
      if (list != null) {
        entitlementHistory.assignAll(
          list
              .map((e) =>
                  AirTicketEntitlement.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
    } catch (e, st) {
      log("❌ fetchAllEntitlements: $e", stackTrace: st);
    } finally {
      isLoadingEntitlement.value = false;
    }
  }

  /// Load a page of the logged-in employee's requests, optionally filtered.
  /// Pass `append: true` to append to the existing list (for infinite scroll).
  Future<void> fetchMyRequests({
    int page = 1,
    int limit = 10,
    String? status,
    bool append = false,
  }) async {
    try {
      isLoadingRequests.value = true;
      final empId = await _employeeId();
      if (empId.isEmpty) return;
      final data = await _repo.getRequests(
        employeeId: empId,
        status: status,
        page: page,
        limit: limit,
      );
      if (data == null) return;
      final parsed = AirTicketRequestList.fromMap(data);
      if (append) {
        requests.addAll(parsed.items);
      } else {
        requests.assignAll(parsed.items);
      }
      currentPage.value = parsed.page;
      totalPages.value = parsed.totalPages;
      if (status != null) statusFilter.value = status;
    } catch (e, st) {
      log("❌ fetchMyRequests: $e", stackTrace: st);
    } finally {
      isLoadingRequests.value = false;
    }
  }

  /// Load full details for a single request.
  Future<void> fetchRequestDetails(String requestId) async {
    try {
      isLoadingDetails.value = true;
      selectedRequest.value = null;
      final data = await _repo.getRequestDetails(requestId);
      if (data != null) {
        selectedRequest.value = AirTicketRequestDetails.fromMap(data);
      }
    } catch (e, st) {
      log("❌ fetchRequestDetails: $e", stackTrace: st);
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Create a new request. Returns the server-assigned request_id on success.
  Future<String?> createRequest(CreateAirTicketRequestDTO dto) async {
    try {
      isSubmitting.value = true;
      final payload = dto.toJson();
      log("✈️ Air ticket create payload: $payload");
      final data = await _repo.createRequest(payload);
      if (data == null) return null;
      // Refresh list so user sees the new request
      await fetchMyRequests(page: 1);
      return data['request_id']?.toString();
    } catch (e, st) {
      log("❌ createRequest: $e", stackTrace: st);
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancel a pending request. Returns true on success.
  Future<bool> cancelRequest(String requestId) async {
    try {
      isCancelling.value = true;
      final ok = await _repo.cancelRequest(requestId);
      if (ok) {
        // Remove locally for instant feedback
        requests.removeWhere((r) => r.requestId == requestId);
      }
      return ok;
    } catch (e, st) {
      log("❌ cancelRequest: $e", stackTrace: st);
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  /// Load booking details for a request (returns null if no booking yet).
  Future<AirTicketBooking?> fetchBooking(String requestId) async {
    try {
      final data = await _repo.getBooking(requestId);
      if (data == null) return null;
      return AirTicketBooking.fromMap(data);
    } catch (e, st) {
      log("❌ fetchBooking: $e", stackTrace: st);
      return null;
    }
  }
}
