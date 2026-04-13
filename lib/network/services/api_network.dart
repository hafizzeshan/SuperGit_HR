import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:get/get.dart' hide Response;
import 'package:supergithr/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/app_urls.dart';

class ApiNetworkService {
  static final ApiNetworkService _instance = ApiNetworkService._internal();
  factory ApiNetworkService() => _instance;

  late Dio dio;
  late CookieJar cookieJar;
  String? authToken;

  static const tokenExpiryDuration = Duration(hours: 20); // ✅ 20 hours

  ApiNetworkService._internal() {
    // Initialize cookie jar for persistent cookies
    cookieJar = CookieJar();

    dio = Dio(
      BaseOptions(
        baseUrl: AppURL.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // Add cookie manager to handle cookies automatically
    // dio.interceptors.add(CookieManager(cookieJar));

    // Add interceptor for detailed logging and 401 handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
          print('🌐 Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print(
            '❌ ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          print('❌ ERROR MESSAGE: ${e.message}');

          // ✅ Handle 401 Unauthorized - Session expired
          // BUT: Skip this for login endpoint (401 there means wrong credentials)
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('auth/login')) {
            print(
              '🔐 401 Unauthorized - Clearing token and redirecting to login',
            );
            await clearAuthToken();

            // Import Get for navigation
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('authToken');
            await prefs.remove('tokenSavedAt');

            // Don't show multiple error messages, just redirect
            // The splash screen or login will handle showing the message
          }

          return handler.next(e);
        },
      ),
    );

    _initializeToken();
  }

  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('tokenSavedAt');
    final token = prefs.getString('authToken');
    final refreshToken = prefs.getString('refreshToken');

    if (token != null && savedTime != null) {
      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedTime);
      final now = DateTime.now();

      if (now.difference(savedAt) > tokenExpiryDuration) {
        // ✅ Token expired
        await clearAuthToken();
        // Don't show snackbar - let the API response handle error messages
        print("⚠️ Token expired (20 hours passed)");
      } else {
        // ✅ Token still valid
        authToken = token;
        dio.options.headers["Authorization"] = "Bearer $authToken";
        // Attach refresh token header if available
        if (refreshToken != null && refreshToken.isNotEmpty) {
          dio.options.headers["X-Refresh-Token"] = refreshToken;
          print('🔁 Refresh token attached to headers');
        }
        print("🔐 Token loaded from SharedPreferences");
      }
    }
  }

  /// ✅ Save token + timestamp
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setInt('tokenSavedAt', DateTime.now().millisecondsSinceEpoch);
    authToken = token;
    dio.options.headers["Authorization"] = "Bearer $token";
    // Ensure refresh token header is present if stored
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      dio.options.headers["X-Refresh-Token"] = refreshToken;
    }
    log("🔑 Token saved to SharedPreferences at ${DateTime.now()}");
  }

  /// ✅ Clear both token and timestamp
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('tokenSavedAt');
    authToken = null;
    dio.options.headers.remove("Authorization");
    // Remove refresh token header as part of clearing auth
    dio.options.headers.remove("X-Refresh-Token");

    log("🚪 Token, headers, and cookies cleared (logged out)");
  }

  Future<void> _attachToken() async {
    if (authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final savedTime = prefs.getInt('tokenSavedAt');
      final refreshToken = prefs.getString('refreshToken');

      if (token != null && savedTime != null) {
        final savedAt = DateTime.fromMillisecondsSinceEpoch(savedTime);
        final now = DateTime.now();

        if (now.difference(savedAt) > tokenExpiryDuration) {
          // ✅ Token expired again check
          await clearAuthToken();
          // Don't show snackbar - let the API response handle error messages
          return;
        } else {
          authToken = token;
          dio.options.headers["Authorization"] = "Bearer $authToken";
          if (refreshToken != null && refreshToken.isNotEmpty) {
            dio.options.headers["X-Refresh-Token"] = refreshToken;
          }
        }
      }
    }
  }

  /// Unified Error Handler - Only logs errors, no snackbars
  void _handleError(DioException e, {bool showSnackbar = true}) {
    String message = "Something went wrong";
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map &&
          (data.containsKey('message') || data.containsKey('error'))) {
        message = data['message'] ?? data['error'] ?? message;
      } else {
        message = data.toString();
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = "Connection Timeout. Please try again.";
    } else if (e.type == DioExceptionType.connectionError) {
      message = "No Internet connection";
    } else if (e.message != null) {
      message = e.message!;
    }

    // ✅ Don't show any snackbar - let the controller/repository handle error display from API response
    // Only log for debugging purposes
    log("❌ API ERROR: $message");
  }

  /// POST Request
  Future<Response?> postRequest(
    String endpoint, {
    dynamic data,
    bool isMultipart = false, // ✅ New flag
  }) async {
    await _attachToken();

    try {
      final response = await dio.post(
        endpoint,
        data: data,
        options: Options(
          headers:
              isMultipart
                  ? {'Content-Type': 'multipart/form-data'}
                  : {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // log("✅ POST $endpoint Success → ${response.data}");
        print("✅ POST $endpoint Success → ${response.data}");
        return response;
      } else {
        // Don't show snackbar - return response so controller can handle error message
        print(
          "Post Request to ${AppURL.baseUrl}$endpoint Failed → ${response.data.toString()}",
        );
        return response; // Return response with error data instead of null
      }
    } on DioException catch (e) {
      _handleError(e);
      // Return the error response if available so controller can extract error message
      return e.response;
    }
  }

  /// GET Request
  Future<Response?> getRequest(String endpoint) async {
    await _attachToken();
    try {
      print("🔹 GET Request to: ${AppURL.baseUrl}$endpoint");
      print("🔹 Headers: ${dio.options.headers}");

      final response = await dio.get(endpoint);

      print("🔹 Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ GET $endpoint Success → ${response.data}");
        return response;
      } else {
        print(
          "❌ GET Request to ${AppURL.baseUrl}$endpoint Failed → Status: ${response.statusCode}, Data: ${response.data}",
        );
        // Don't show snackbar - return response so controller can handle error message
        return response; // Return response with error data instead of null
      }
    } on DioException catch (e) {
      print("❌ DioException in GET Request to ${AppURL.baseUrl}$endpoint");
      print("❌ Error Type: ${e.type}");
      print("❌ Error Message: ${e.message}");
      print("❌ Response Status: ${e.response?.statusCode}");
      print("❌ Response Data: ${e.response?.data}");
      print("❌ Request Headers: ${e.requestOptions.headers}");
      _handleError(e);
      // Return the error response if available so controller can extract error message
      return e.response;
    }
  }
}
