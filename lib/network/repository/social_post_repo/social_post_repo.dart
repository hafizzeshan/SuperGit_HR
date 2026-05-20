import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class SocialPostRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// Extract `data` from `{status, message, data}` envelope.
  dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  String _errorMessage(dynamic body, String fallback) {
    if (body is Map) {
      final m = body['message'] ?? body['error'];
      if (m is String && m.isNotEmpty) return m;
    }
    return fallback;
  }

  // ─── Posts ───────────────────────────────────────────────────

  /// GET /social-posts?page&limit
  /// Returns the full envelope (data + pagination) so caller can read both.
  Future<Map<String, dynamic>?> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = AppURL.socialPostsList(page: page, limit: limit);
      final res = await _api.getRequest(url);
      if (res == null) return null;
      if (res.statusCode == 200) {
        return res.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(res.data)
            : null;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to load posts"), true);
      return null;
    } catch (e, st) {
      log("❌ getPosts: $e", stackTrace: st);
      return null;
    }
  }

  /// GET /social-posts/:id
  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final res = await _api.getRequest(AppURL.socialPostDetails(postId));
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to load post"), true);
      return null;
    } catch (e, st) {
      log("❌ getPost: $e", stackTrace: st);
      return null;
    }
  }

  /// POST /social-posts (multipart)
  Future<Map<String, dynamic>?> createPost({
    required String title,
    String? content,
    required String mediaType,
    required String mediaPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        if (content != null) 'content': content,
        'media_type': mediaType,
        'media': await MultipartFile.fromFile(
          mediaPath,
          filename: mediaPath.split('/').last,
        ),
      });
      final res = await _api.postRequest(
        AppURL.socialPostsBase,
        data: formData,
        isMultipart: true,
      );
      if (res == null) return null;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ?? "Post created",
          false,
        );
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to create post"), true);
      return null;
    } catch (e, st) {
      log("❌ createPost: $e", stackTrace: st);
      Utils.snackBar("Something went wrong while creating post", true);
      return null;
    }
  }

  /// PUT /social-posts/:id (multipart, all fields optional)
  Future<Map<String, dynamic>?> updatePost({
    required String postId,
    String? title,
    String? content,
    String? mediaPath,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (title != null) fields['title'] = title;
      if (content != null) fields['content'] = content;
      if (mediaPath != null) {
        fields['media'] = await MultipartFile.fromFile(
          mediaPath,
          filename: mediaPath.split('/').last,
        );
      }
      final formData = FormData.fromMap(fields);
      final res = await _api.putRequest(
        AppURL.socialPostDetails(postId),
        data: formData,
        isMultipart: true,
      );
      if (res == null) return null;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ?? "Post updated",
          false,
        );
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to update post"), true);
      return null;
    } catch (e, st) {
      log("❌ updatePost: $e", stackTrace: st);
      return null;
    }
  }

  /// DELETE /social-posts/:id
  Future<bool> deletePost(String postId) async {
    try {
      final res = await _api.deleteRequest(AppURL.socialPostDetails(postId));
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 204) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ?? "Post deleted",
          false,
        );
        return true;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to delete post"), true);
      return false;
    } catch (e, st) {
      log("❌ deletePost: $e", stackTrace: st);
      return false;
    }
  }

  // ─── Likes ───────────────────────────────────────────────────

  Future<bool> likePost(String postId) async {
    try {
      final res = await _api.postRequest(AppURL.socialPostLike(postId));
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 201) return true;
      Utils.snackBar(_errorMessage(res.data, "Failed to like post"), true);
      return false;
    } catch (e, st) {
      log("❌ likePost: $e", stackTrace: st);
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      final res = await _api.deleteRequest(AppURL.socialPostLike(postId));
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 204) return true;
      Utils.snackBar(_errorMessage(res.data, "Failed to unlike post"), true);
      return false;
    } catch (e, st) {
      log("❌ unlikePost: $e", stackTrace: st);
      return false;
    }
  }

  // ─── Comments ────────────────────────────────────────────────

  Future<List<dynamic>?> getComments(String postId) async {
    try {
      final res = await _api.getRequest(AppURL.socialPostComments(postId));
      if (res == null) return null;
      if (res.statusCode == 200) {
        final data = _unwrap(res.data);
        return data is List ? data : <dynamic>[];
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to load comments"), true);
      return null;
    } catch (e, st) {
      log("❌ getComments: $e", stackTrace: st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final res = await _api.postRequest(
        AppURL.socialPostComments(postId),
        data: {'comment': comment},
      );
      if (res == null) return null;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = _unwrap(res.data);
        return data is Map<String, dynamic> ? data : null;
      }
      Utils.snackBar(_errorMessage(res.data, "Failed to add comment"), true);
      return null;
    } catch (e, st) {
      log("❌ addComment: $e", stackTrace: st);
      return null;
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final res = await _api.deleteRequest(
        AppURL.socialPostComment(postId, commentId),
      );
      if (res == null) return false;
      if (res.statusCode == 200 || res.statusCode == 204) {
        Utils.snackBar(
          (res.data is Map ? res.data['message'] : null) ?? "Comment deleted",
          false,
        );
        return true;
      }
      Utils.snackBar(
          _errorMessage(res.data, "Failed to delete comment"), true);
      return false;
    } catch (e, st) {
      log("❌ deleteComment: $e", stackTrace: st);
      return false;
    }
  }
}
