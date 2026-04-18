import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/air_ticket_controller.dart';
import 'package:supergithr/models/air_ticket_models.dart';
import 'package:supergithr/screens/dashboard_screens/home/air_tickets/air_ticket_details_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/air_tickets/create_air_ticket_screen.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class AirTicketsScreen extends StatefulWidget {
  const AirTicketsScreen({super.key});

  @override
  State<AirTicketsScreen> createState() => _AirTicketsScreenState();
}

class _AirTicketsScreenState extends State<AirTicketsScreen> {
  final AirTicketController c = Get.find<AirTicketController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.fetchEntitlement();
      c.fetchMyRequests();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      c.fetchEntitlement(),
      c.fetchMyRequests(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: "Air Tickets"),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: () async {
          await Get.to(() => const CreateAirTicketRequestScreen());
          // Controller already refreshes list after successful create;
          // this extra refresh covers the case the user came back manually.
          c.fetchMyRequests();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Request",
            style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _entitlementCard(),
              const SizedBox(height: 16),
              Text("My Requests",
                  style: textStyleMontserratBold(
                      fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 8),
              _requestsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entitlementCard() {
    return Obx(() {
      if (c.isLoadingEntitlement.value && c.entitlement.value == null) {
        return _cardShell(
          child: const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      final e = c.entitlement.value;
      if (e == null) {
        return _cardShell(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text("No entitlement found for this year.",
                style: textStyleMontserratBold(
                    fontSize: 14, color: Colors.black54)),
          ),
        );
      }
      final progress = e.eligibleTickets == 0
          ? 0.0
          : (e.usedTickets / e.eligibleTickets).clamp(0.0, 1.0);
      return _cardShell(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flight_takeoff, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text("Entitlement · ${e.year}",
                      style: textStyleMontserratBold(
                          fontSize: 15, color: Colors.black87)),
                  const Spacer(),
                  _statusChip(e.status),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Used: ${e.usedTickets}/${e.eligibleTickets}",
                      style: const TextStyle(color: Colors.black87)),
                  Text("Remaining: ${e.remainingTickets}",
                      style: textStyleMontserratBold(
                          fontSize: 13, color: kPrimaryColor)),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _requestsList() {
    return Obx(() {
      if (c.isLoadingRequests.value && c.requests.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (c.requests.isEmpty) {
        return _cardShell(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.airplanemode_inactive,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text("No air ticket requests yet.",
                    style: textStyleMontserratBold(
                        fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        );
      }
      return Column(
        children: c.requests.map(_requestTile).toList(),
      );
    });
  }

  Widget _requestTile(AirTicketRequest r) {
    final dep = r.departureDate == null
        ? '—'
        : DateFormat('MMM d, yyyy').format(r.departureDate!);
    return GestureDetector(
      onTap: () =>
          Get.to(() => AirTicketDetailsScreen(requestId: r.requestId)),
      child: _cardShell(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${r.fromCity} → ${r.toCity}",
                    style: textStyleMontserratBold(
                        fontSize: 15, color: Colors.black87),
                  ),
                ),
                _statusChip(r.status),
              ],
            ),
            const SizedBox(height: 6),
            Text("Departure: $dep",
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              "${r.travelClass.toUpperCase()} · ${r.travelType.replaceAll('_', ' ')}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      case 'cancelled':
      case 'expired':
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? '—' : status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cardShell({required Widget child, EdgeInsets? margin}) {
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
}
