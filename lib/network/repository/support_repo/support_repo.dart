import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supergithr/models/support_request_model.dart';
import 'package:supergithr/network/services/support_email_service.dart';

/// Firestore access for employee support requests.
///
/// Sending writes the record to `support_requests`, which is also what the
/// app reads back and shows as tiles.
/// Delivery goes through [SupportEmailService] (Web3Forms) — no SMTP server
/// and no Firebase Blaze plan needed.
class SupportRepository {
  static const String requestsCollection = 'support_requests';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupportEmailService _email = SupportEmailService();

  /// Today's requests for one employee.
  ///
  /// Two equality filters only — deliberately no `orderBy`, because that would
  /// need a composite index. The list is small, so it's sorted in Dart.
  Future<List<SupportRequestModel>> fetchForDay({
    required String employeeId,
    required String dayKey,
  }) async {
    final snap =
        await _db
            .collection(requestsCollection)
            .where('employee_id', isEqualTo: employeeId)
            .where('day_key', isEqualTo: dayKey)
            .get();

    final items = snap.docs.map(SupportRequestModel.fromDoc).toList();
    // Newest first; a doc whose server timestamp hasn't landed yet sorts top.
    items.sort((a, b) {
      final at = a.createdAt, bt = b.createdAt;
      if (at == null) return -1;
      if (bt == null) return 1;
      return bt.compareTo(at);
    });
    return items;
  }

  /// Stores the request, then emails it. The Firestore record is written
  /// first and kept even if delivery fails, so nothing an employee typed is
  /// ever lost; `email_status` on the document says what happened.
  Future<String> send({
    required SupportRequestModel request,
    required String appVersion,
  }) async {
    final doc = await _db
        .collection(requestsCollection)
        .add(request.toFirestore());

    final delivered = await _email.send(
      request: request,
      referenceId: doc.id,
      appVersion: appVersion,
    );

    await doc.update({'email_status': delivered ? 'sent' : 'failed'});
    return doc.id;
  }
}
