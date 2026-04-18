import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/air_ticket_controller.dart';
import 'package:supergithr/models/air_ticket_models.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class CreateAirTicketRequestScreen extends StatefulWidget {
  const CreateAirTicketRequestScreen({super.key});

  @override
  State<CreateAirTicketRequestScreen> createState() =>
      _CreateAirTicketRequestScreenState();
}

class _CreateAirTicketRequestScreenState
    extends State<CreateAirTicketRequestScreen> {
  final AirTicketController c = Get.find<AirTicketController>();

  final _formKey = GlobalKey<FormState>();
  final _fromCity = TextEditingController();
  final _toCity = TextEditingController();
  final _airline = TextEditingController();
  final _remarks = TextEditingController();

  String _requestType = 'annual_leave';
  String _travelClass = 'economy';
  String _travelType = 'self';
  DateTime? _departureDate;
  DateTime? _returnDate;

  final List<_PassengerInput> _passengers = [];

  static const _requestTypes = ['annual_leave', 'emergency', 'personal'];
  static const _travelClasses = ['economy', 'business', 'first'];
  static const _travelTypes = ['self', 'self_family'];
  static const _relationships = ['spouse', 'child', 'parent', 'sibling'];

  @override
  void dispose() {
    _fromCity.dispose();
    _toCity.dispose();
    _airline.dispose();
    _remarks.dispose();
    for (final p in _passengers) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: "New Air Ticket Request"),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle("Trip"),
              _dropdownCard(
                label: "Request Type",
                icon: Icons.category_rounded,
                value: _requestType,
                items: _requestTypes,
                onChanged: (v) => setState(() => _requestType = v!),
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _fromCity,
                label: "From City",
                icon: Icons.flight_takeoff,
                validator: _required,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _toCity,
                label: "To City",
                icon: Icons.flight_land,
                validator: _required,
              ),
              const SizedBox(height: 12),
              _dateCard(
                label: "Departure Date *",
                icon: Icons.calendar_today,
                value: _departureDate,
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 12),
              _dateCard(
                label: "Return Date (optional)",
                icon: Icons.event,
                value: _returnDate,
                onTap: () => _pickDate(false),
                clearable: true,
                onClear: () => setState(() => _returnDate = null),
              ),
              const SizedBox(height: 12),
              _dropdownCard(
                label: "Travel Class",
                icon: Icons.airline_seat_recline_normal,
                value: _travelClass,
                items: _travelClasses,
                onChanged: (v) => setState(() => _travelClass = v!),
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _airline,
                label: "Preferred Airline (optional)",
                icon: Icons.flight,
              ),
              const SizedBox(height: 20),
              _sectionTitle("Travel Type"),
              _dropdownCard(
                label: "Who is travelling?",
                icon: Icons.group,
                value: _travelType,
                items: _travelTypes,
                labelBuilder: (v) =>
                    v == 'self' ? 'Self only' : 'Self + family',
                onChanged: (v) => setState(() => _travelType = v!),
              ),
              if (_travelType == 'self_family') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _sectionTitle("Passengers")),
                    TextButton.icon(
                      onPressed: _addPassenger,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add"),
                    ),
                  ],
                ),
                if (_passengers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Add at least one passenger",
                      style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                    ),
                  ),
                ..._passengers.asMap().entries.map(
                      (e) => _passengerCard(e.key, e.value),
                    ),
              ],
              const SizedBox(height: 20),
              _sectionTitle("Remarks"),
              _textField(
                controller: _remarks,
                label: "Notes (optional)",
                icon: Icons.note_alt_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Obx(
                () => ElevatedButton(
                  onPressed: c.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: c.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Submit Request",
                          style: textStyleMontserratBold(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── form helpers ────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? "Required" : null;

  Future<void> _pickDate(bool isDeparture) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departureDate ?? now)
        : (_returnDate ?? _departureDate ?? now);
    final firstDate = isDeparture ? now : (_departureDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  void _addPassenger() {
    setState(() => _passengers.add(_PassengerInput()));
  }

  void _removePassenger(int index) {
    setState(() {
      _passengers[index].dispose();
      _passengers.removeAt(index);
    });
  }

  Future<void> _pickPassengerDob(_PassengerInput p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: p.dob ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => p.dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null) {
      Utils.snackBar("Please select a departure date", true);
      return;
    }
    if (_travelType == 'self_family' && _passengers.isEmpty) {
      Utils.snackBar("Add at least one passenger", true);
      return;
    }

    // Validate passenger inputs
    final passengerModels = <AirTicketPassenger>[];
    for (final p in _passengers) {
      if (p.name.text.trim().isEmpty || p.passport.text.trim().isEmpty) {
        Utils.snackBar("Fill name and passport for every passenger", true);
        return;
      }
      if (p.dob == null) {
        Utils.snackBar("Pick date of birth for every passenger", true);
        return;
      }
      passengerModels.add(
        AirTicketPassenger(
          name: p.name.text.trim(),
          relationship: p.relationship,
          passportNumber: p.passport.text.trim(),
          iqamaNumber: p.iqama.text.trim().isEmpty ? null : p.iqama.text.trim(),
          dateOfBirth: p.dob,
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final empId = prefs.getString('employee_id') ?? '';
    if (empId.isEmpty) {
      Utils.snackBar("Employee ID missing. Please log in again.", true);
      return;
    }

    final dto = CreateAirTicketRequestDTO(
      employeeId: empId,
      requestType: _requestType,
      fromCity: _fromCity.text.trim(),
      toCity: _toCity.text.trim(),
      departureDate: _departureDate!,
      returnDate: _returnDate,
      preferredAirline:
          _airline.text.trim().isEmpty ? null : _airline.text.trim(),
      travelClass: _travelClass,
      travelType: _travelType,
      passengers: passengerModels,
      remarks: _remarks.text.trim().isEmpty ? null : _remarks.text.trim(),
    );

    final requestId = await c.createRequest(dto);
    if (requestId != null) Get.back();
  }

  // ─── UI pieces ───────────────────────────────────────────────

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          t,
          style: textStyleMontserratBold(fontSize: 14, color: Colors.black87),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _dropdownCard({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
          border: InputBorder.none,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(labelBuilder?.call(e) ?? _pretty(e)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dateCard({
    required String label,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value == null
                        ? "Tap to select"
                        : DateFormat('MMM d, yyyy').format(value),
                    style: TextStyle(
                      color: value == null ? Colors.grey.shade400 : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (clearable && value != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey.shade500,
              ),
          ],
        ),
      ),
    );
  }

  Widget _passengerCard(int index, _PassengerInput p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Passenger ${index + 1}",
                style:
                    textStyleMontserratBold(fontSize: 13, color: Colors.black87),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removePassenger(index),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
          _miniField(p.name, "Full Name"),
          const SizedBox(height: 8),
          _miniDropdown(
            value: p.relationship,
            onChanged: (v) => setState(() => p.relationship = v),
            items: _relationships,
            hint: "Relationship (optional)",
          ),
          const SizedBox(height: 8),
          _miniField(p.passport, "Passport Number"),
          const SizedBox(height: 8),
          _miniField(p.iqama, "Iqama Number (optional)"),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickPassengerDob(p),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined,
                      size: 18, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text(
                    p.dob == null
                        ? "Date of Birth"
                        : DateFormat('MMM d, yyyy').format(p.dob!),
                    style: TextStyle(
                      color: p.dob == null
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _miniDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(_pretty(e))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _pretty(String v) =>
      v.replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
}

class _PassengerInput {
  final TextEditingController name = TextEditingController();
  final TextEditingController passport = TextEditingController();
  final TextEditingController iqama = TextEditingController();
  String? relationship;
  DateTime? dob;

  void dispose() {
    name.dispose();
    passport.dispose();
    iqama.dispose();
  }
}
