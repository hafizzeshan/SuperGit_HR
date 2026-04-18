import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/air_ticket_controller.dart';
import 'package:supergithr/models/air_ticket_models.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class AirTicketDetailsScreen extends StatefulWidget {
  final String requestId;
  const AirTicketDetailsScreen({super.key, required this.requestId});

  @override
  State<AirTicketDetailsScreen> createState() => _AirTicketDetailsScreenState();
}

class _AirTicketDetailsScreenState extends State<AirTicketDetailsScreen> {
  final AirTicketController c = Get.find<AirTicketController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.fetchRequestDetails(widget.requestId);
    });
  }

  Future<void> _confirmCancel(AirTicketRequest req) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel Request?"),
        content: Text(
          "This will cancel request ${req.requestId}. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Keep"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Cancel Request"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await c.cancelRequest(req.requestId);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: "Request Details"),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          if (c.isLoadingDetails.value && c.selectedRequest.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = c.selectedRequest.value;
          if (d == null) {
            return const Center(child: Text("Request not found"));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(d.request),
              const SizedBox(height: 14),
              _tripCard(d.request),
              const SizedBox(height: 14),
              if (d.passengers.isNotEmpty) ...[
                _sectionTitle("Passengers"),
                ...d.passengers.map(_passengerTile),
                const SizedBox(height: 14),
              ],
              _sectionTitle("Approval Timeline"),
              _approvalTimeline(d.approvals),
              const SizedBox(height: 14),
              if (d.booking != null) ...[
                _sectionTitle("Booking"),
                _bookingCard(d.booking!),
                const SizedBox(height: 14),
              ],
              if (d.request.status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 8),
                Obx(() => ElevatedButton.icon(
                      onPressed: c.isCancelling.value
                          ? null
                          : () => _confirmCancel(d.request),
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.white),
                      label: c.isCancelling.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Cancel Request",
                              style: textStyleMontserratBold(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }

  // ─── Cards ──────────────────────────────────────────────────

  Widget _headerCard(AirTicketRequest r) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    color: kPrimaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.requestId,
                    style: textStyleMontserratBold(
                        fontSize: 16, color: Colors.black87),
                  ),
                ),
                _statusChip(r.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${r.fromCity} → ${r.toCity}",
              style: textStyleMontserratBold(
                  fontSize: 18, color: Colors.black87),
            ),
            if (r.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                "Requested ${DateFormat('MMM d, yyyy').format(r.createdAt!)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tripCard(AirTicketRequest r) {
    final dep = r.departureDate == null
        ? '—'
        : DateFormat('MMM d, yyyy').format(r.departureDate!);
    final ret = r.returnDate == null
        ? '—'
        : DateFormat('MMM d, yyyy').format(r.returnDate!);
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _kv("Request Type", _pretty(r.requestType)),
            _kv("Travel Type", _pretty(r.travelType)),
            _kv("Travel Class", r.travelClass.toUpperCase()),
            _kv("Departure", dep),
            _kv("Return", ret),
            if ((r.preferredAirline ?? '').isNotEmpty)
              _kv("Preferred Airline", r.preferredAirline!),
            if (r.estimatedCost != null)
              _kv("Estimated Cost",
                  "${r.estimatedCost!.toStringAsFixed(2)} ${r.currency ?? ''}"),
            if ((r.remarks ?? '').isNotEmpty) _kv("Remarks", r.remarks!),
          ],
        ),
      ),
    );
  }

  Widget _passengerTile(AirTicketPassenger p) {
    final dob = p.dateOfBirth == null
        ? ''
        : DateFormat('MMM d, yyyy').format(p.dateOfBirth!);
    return _card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: const Icon(Icons.person, color: kPrimaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: textStyleMontserratBold(
                              fontSize: 14, color: Colors.black87)),
                      if ((p.relationship ?? '').isNotEmpty ||
                          (p.passengerType ?? '').isNotEmpty)
                        Text(
                          _pretty(p.relationship ?? p.passengerType ?? ''),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _kv("Passport", p.passportNumber),
            if ((p.iqamaNumber ?? '').isNotEmpty) _kv("Iqama", p.iqamaNumber!),
            if (dob.isNotEmpty) _kv("DOB", dob),
          ],
        ),
      ),
    );
  }

  Widget _approvalTimeline(List<AirTicketApproval> approvals) {
    if (approvals.isEmpty) {
      return _card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("No approval actions yet.",
              style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(approvals.length, (i) {
            final a = approvals[i];
            final isLast = i == approvals.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _actionColor(a.action).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_actionIcon(a.action),
                            color: _actionColor(a.action), size: 16),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: Colors.grey.shade200),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 4 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_pretty(a.stage)} · ${_pretty(a.action)}",
                            style: textStyleMontserratBold(
                                fontSize: 13, color: Colors.black87),
                          ),
                          if (a.actionAt != null)
                            Text(
                              DateFormat('MMM d, yyyy · hh:mm a')
                                  .format(a.actionAt!.toLocal()),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 11),
                            ),
                          if ((a.comments ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                a.comments!,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _bookingCard(AirTicketBooking b) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.airplane_ticket, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(b.airline,
                    style: textStyleMontserratBold(
                        fontSize: 15, color: Colors.black87)),
                const Spacer(),
                _statusChip(b.bookingStatus),
              ],
            ),
            const SizedBox(height: 8),
            _kv("PNR", b.pnr),
            _kv("Ticket", b.ticketNumber),
            if ((b.travelAgency ?? '').isNotEmpty)
              _kv("Agency", b.travelAgency!),
            _kv("Final Cost", b.finalCost.toStringAsFixed(2)),
            if ((b.invoiceNumber ?? '').isNotEmpty)
              _kv("Invoice", b.invoiceNumber!),
            if (b.issuedAt != null)
              _kv("Issued", DateFormat('MMM d, yyyy').format(b.issuedAt!)),
          ],
        ),
      ),
    );
  }

  // ─── Shared ─────────────────────────────────────────────────

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(t,
            style: textStyleMontserratBold(fontSize: 14, color: Colors.black87)),
      );

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(color: Colors.black87, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statusChip(String status) {
    Color bg, fg;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
      case 'rejected':
      case 'cancelled':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.isEmpty ? '—' : status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _actionColor(String action) {
    switch (action.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _actionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'approved':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _pretty(String v) => v.isEmpty
      ? ''
      : v.replaceAll('_', ' ').replaceFirstMapped(
          RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
}
