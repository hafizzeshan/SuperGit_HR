import 'package:dio/dio.dart';
import 'package:supergithr/models/support_request_model.dart';
import 'package:supergithr/services/force_update_service.dart';

/// Delivers support requests by email through Web3Forms.
///
/// Chosen because it needs no SMTP server, no backend and no Firebase Blaze
/// plan — the app posts a JSON body and Web3Forms sends the mail. The access
/// key lives in Remote Config so it can be rotated without a release.
///
/// Note: Web3Forms always delivers to the address the access key was created
/// with — deliberate on their side, so a leaked key can't be used to spam
/// arbitrary inboxes. To change where support mail lands, change it in the
/// Web3Forms dashboard, or swap the key for one made on another account.
class SupportEmailService {
  static const String _endpoint = 'https://api.web3forms.com/submit';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Read the body ourselves on any status instead of throwing.
      validateStatus: (_) => true,
    ),
  );

  bool get isConfigured => ForceUpdateService.supportFormKey.isNotEmpty;

  /// Returns true when Web3Forms accepted the message.
  Future<bool> send({
    required SupportRequestModel request,
    required String referenceId,
    required String appVersion,
  }) async {
    final key = ForceUpdateService.supportFormKey;
    if (key.isEmpty) {
      print('⚠️ support_form_access_key is empty — email not sent');
      return false;
    }

    try {
      final response = await _dio.post(
        _endpoint,
        data: {
          'access_key': key,
          'subject':
              'Support request — ${request.employeeName.isEmpty ? request.employeeCode : request.employeeName}',
          'from_name': 'SuperGit HR',
          // Support can hit reply and reach the employee directly. Omitted
          // when the profile carries no email, so we never send a blank one.
          if (request.email.isNotEmpty) 'replyto': request.email,
          'Employee name': request.employeeName,
          'Employee code': request.employeeCode,
          'Employee ID': request.employeeId,
          'Phone': request.phone,
          'Email': request.email,
          'App version': appVersion,
          'Reference': referenceId,
          'Message': request.message,
        },
      );

      final body = response.data;
      final ok =
          response.statusCode == 200 && body is Map && body['success'] == true;

      print(
        ok
            ? '📧 Support email sent (ref $referenceId)'
            : '⚠️ Support email failed [${response.statusCode}]: $body',
      );
      return ok;
    } catch (e) {
      print('⚠️ Support email failed: $e');
      return false;
    }
  }
}
