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
import 'package:supergithr/translations/translations/translation_keys.dart';

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
      appBar: appBarrWitoutAction(title: TranslationKeys.newAirTicketRequest.tr),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _sectionCard(
                icon: Icons.flight_outlined,
                title: TranslationKeys.tripDetails.tr,
                subtitle: TranslationKeys.whereAndWhenFlying.tr,
                children: [
                  _fieldLabel(TranslationKeys.requestType.tr),
                  _selectorTile(
                    icon: Icons.category_rounded,
                    value: _pretty(_requestType),
                    hint: TranslationKeys.chooseRequestType.tr,
                    onTap: () => _openPicker(
                      title: TranslationKeys.requestType.tr,
                      items: _requestTypes,
                      selected: _requestType,
                      onSelected: (v) =>
                          setState(() => _requestType = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel(TranslationKeys.fromCity.tr),
                  _textField(
                    controller: _fromCity,
                    icon: Icons.flight_takeoff,
                    hint: TranslationKeys.egRiyadh.tr,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel(TranslationKeys.toCity.tr),
                  _textField(
                    controller: _toCity,
                    icon: Icons.flight_land,
                    hint: TranslationKeys.egDubai.tr,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("${TranslationKeys.departure.tr} *"),
                            _dateTile(
                              icon: Icons.calendar_today_rounded,
                              value: _departureDate,
                              hint: TranslationKeys.selectDate.tr,
                              onTap: () => _pickDate(true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(TranslationKeys.returnOptional.tr),
                            _dateTile(
                              icon: Icons.event_rounded,
                              value: _returnDate,
                              hint: TranslationKeys.selectDate.tr,
                              onTap: () => _pickDate(false),
                              clearable: true,
                              onClear: () =>
                                  setState(() => _returnDate = null),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel(TranslationKeys.travelClass.tr),
                  _selectorTile(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    value: _pretty(_travelClass),
                    hint: TranslationKeys.chooseClass.tr,
                    onTap: () => _openPicker(
                      title: TranslationKeys.travelClass.tr,
                      items: _travelClasses,
                      selected: _travelClass,
                      onSelected: (v) =>
                          setState(() => _travelClass = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel(TranslationKeys.preferredAirline.tr),
                  _textField(
                    controller: _airline,
                    icon: Icons.flight_rounded,
                    hint: TranslationKeys.optional.tr,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                icon: Icons.group_outlined,
                title: TranslationKeys.travelParty.tr,
                subtitle: TranslationKeys.whoIsTravelling.tr,
                children: [
                  _fieldLabel(TranslationKeys.travelType.tr),
                  _selectorTile(
                    icon: Icons.people_alt_rounded,
                    value: _travelTypeLabel(_travelType),
                    hint: TranslationKeys.chooseTravelType.tr,
                    onTap: () => _openPicker(
                      title: TranslationKeys.travelType.tr,
                      items: _travelTypes,
                      selected: _travelType,
                      labelBuilder: _travelTypeLabel,
                      onSelected: (v) =>
                          setState(() => _travelType = v),
                    ),
                  ),
                ],
              ),
              if (_travelType == 'self_family') ...[
                const SizedBox(height: 16),
                _passengersCard(),
              ],
              const SizedBox(height: 16),
              _sectionCard(
                icon: Icons.note_alt_outlined,
                title: TranslationKeys.notes.tr,
                subtitle: TranslationKeys.anythingElseToKnow.tr,
                children: [
                  _fieldLabel(TranslationKeys.remarks.tr),
                  _textField(
                    controller: _remarks,
                    icon: Icons.edit_note_rounded,
                    hint: TranslationKeys.optionalNotesForHr.tr,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: c.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: c.isSubmitting.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                TranslationKeys.submitRequest.tr,
                                style: textStyleMontserratBold(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── form helpers ────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? TranslationKeys.required.tr : null;

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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: kPrimaryColor),
        ),
        child: child!,
      ),
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => p.dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null) {
      Utils.snackBar(TranslationKeys.pleaseSelectDepartureDate.tr, true);
      return;
    }
    if (_travelType == 'self_family' && _passengers.isEmpty) {
      Utils.snackBar(TranslationKeys.addAtLeastOnePassenger.tr, true);
      return;
    }

    final passengerModels = <AirTicketPassenger>[];
    for (final p in _passengers) {
      if (p.name.text.trim().isEmpty || p.passport.text.trim().isEmpty) {
        Utils.snackBar(TranslationKeys.fillNameAndPassport.tr, true);
        return;
      }
      if (p.dob == null) {
        Utils.snackBar(TranslationKeys.pickDobForEveryPassenger.tr, true);
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
      Utils.snackBar(TranslationKeys.employeeIdMissingLogin.tr, true);
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

  // ─── bottom sheet picker ─────────────────────────────────────

  Future<void> _openPicker({
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
    String Function(String)? labelBuilder,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: textStyleMontserratBold(
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((e) {
                final label = labelBuilder?.call(e) ?? _pretty(e);
                final isSelected = e == selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    onSelected(e);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? kPrimaryColor
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? kPrimaryColor
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: kPrimaryColor, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ─── UI pieces ───────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyleMontserratBold(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }

  Widget _selectorTile({
    required IconData icon,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isEmpty
                      ? Colors.grey.shade400
                      : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade500, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? hint
                    : DateFormat('MMM d, yyyy').format(value),
                style: TextStyle(
                  fontSize: 13.5,
                  color:
                      value == null ? Colors.grey.shade400 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (clearable && value != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 18, color: Colors.grey.shade500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _passengersCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_outline_rounded,
                    color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.passengers.tr,
                      style: textStyleMontserratBold(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${_passengers.length} ${TranslationKeys.added.tr}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addPassenger,
                style: TextButton.styleFrom(
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.08),
                  foregroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(TranslationKeys.add.tr),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),
          if (_passengers.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      TranslationKeys.addAtLeastOnePassenger.tr,
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._passengers
                .asMap()
                .entries
                .map((e) => _passengerCard(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _passengerCard(int index, _PassengerInput p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${TranslationKeys.passenger.tr} ${index + 1}",
                  style: textStyleMontserratBold(
                    fontSize: 12,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removePassenger(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _fieldLabel(TranslationKeys.fullName.tr),
          _textField(
            controller: p.name,
            icon: Icons.person_outline_rounded,
            hint: TranslationKeys.passengerName.tr,
          ),
          const SizedBox(height: 12),
          _fieldLabel(TranslationKeys.relationship.tr),
          _selectorTile(
            icon: Icons.family_restroom_rounded,
            value: p.relationship == null ? "" : _pretty(p.relationship!),
            hint: TranslationKeys.selectRelationship.tr,
            onTap: () => _openPicker(
              title: TranslationKeys.relationship.tr,
              items: _relationships,
              selected: p.relationship ?? '',
              onSelected: (v) => setState(() => p.relationship = v),
            ),
          ),
          const SizedBox(height: 12),
          _fieldLabel(TranslationKeys.passportNumber.tr),
          _textField(
            controller: p.passport,
            icon: Icons.badge_outlined,
            hint: TranslationKeys.passportNumber.tr,
          ),
          const SizedBox(height: 12),
          _fieldLabel(TranslationKeys.iqamaNumber.tr),
          _textField(
            controller: p.iqama,
            icon: Icons.credit_card_rounded,
            hint: TranslationKeys.optional.tr,
          ),
          const SizedBox(height: 12),
          _fieldLabel(TranslationKeys.dateOfBirth.tr),
          _dateTile(
            icon: Icons.cake_outlined,
            value: p.dob,
            hint: TranslationKeys.selectDob.tr,
            onTap: () => _pickPassengerDob(p),
          ),
        ],
      ),
    );
  }

  String _travelTypeLabel(String v) =>
      v == 'self' ? TranslationKeys.selfOnly.tr : TranslationKeys.selfFamily.tr;

  String _pretty(String v) => v.replaceAll('_', ' ').replaceFirstMapped(
      RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
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
