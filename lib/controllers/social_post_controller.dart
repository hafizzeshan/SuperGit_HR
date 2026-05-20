import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/social_post_model.dart';
import 'package:supergithr/network/repository/social_post_repo/social_post_repo.dart';

class SocialPostController extends GetxController {
  final SocialPostRepository _repo = SocialPostRepository();

  /// True only for admin / HR / superadmin — gates create/edit/delete UI.
  final RxBool isAdmin = false.obs;

  // Feed state
  final RxList<SocialPost> posts = <SocialPost>[].obs;
  final RxBool isLoadingFeed = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt page = 1.obs;
  final RxInt total = 0.obs;
  final int limit = 10;

  // Detail state
  final Rxn<SocialPost> selectedPost = Rxn<SocialPost>();
  final RxBool isLoadingDetail = false.obs;

  // Comment state
  final RxBool isPostingComment = false.obs;

  // Mutation flags
  final RxBool isSubmittingPost = false.obs;
  final RxBool isDeletingPost = false.obs;

  bool get hasMore => posts.length < total.value;

  @override
  void onInit() {
    super.onInit();
    loadAuth();
  }

  /// Reload the admin flag from prefs (set at login).
  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    isAdmin.value = prefs.getBool('is_admin') ?? false;
  }

  Future<void> fetchFeed({bool refresh = true}) async {
    if (refresh) {
      isLoadingFeed.value = true;
      page.value = 1;
    } else {
      if (isLoadingMore.value || !hasMore) return;
      isLoadingMore.value = true;
    }
    try {
      final res = await _repo.getPosts(page: page.value, limit: limit);
      if (res != null) {
        final list = (res['data'] as List? ?? [])
            .map((e) => SocialPost.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        final pag = Map<String, dynamic>.from(res['pagination'] ?? {});
        total.value = (pag['total'] is num)
            ? (pag['total'] as num).toInt()
            : list.length;
        if (refresh) {
          posts.assignAll(list);
        } else {
          posts.addAll(list);
        }
      }
    } catch (e, st) {
      log("❌ fetchFeed: $e", stackTrace: st);
    } finally {
      isLoadingFeed.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoadingFeed.value || !hasMore) return;
    page.value += 1;
    await fetchFeed(refresh: false);
  }

  /// [showLoader] clears the current post first (full loading state). Pass
  /// false for silent refreshes (e.g. after adding a comment) so the video
  /// player isn't torn down and restarted.
  Future<void> fetchDetail(String postId, {bool showLoader = true}) async {
    isLoadingDetail.value = true;
    if (showLoader) selectedPost.value = null;
    try {
      final data = await _repo.getPost(postId);
      if (data != null) {
        selectedPost.value = SocialPost.fromMap(data);
      }
    } catch (e, st) {
      log("❌ fetchDetail: $e", stackTrace: st);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Optimistic toggle of like/unlike. Reverts on API failure.
  Future<void> toggleLike(SocialPost post) async {
    final wasLiked = post.isLiked;
    _replacePost(post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    ));

    final ok = wasLiked
        ? await _repo.unlikePost(post.id)
        : await _repo.likePost(post.id);

    if (!ok) {
      _replacePost(post); // revert
    }
  }

  void _replacePost(SocialPost updated) {
    final i = posts.indexWhere((p) => p.id == updated.id);
    if (i >= 0) posts[i] = updated;
    if (selectedPost.value?.id == updated.id) selectedPost.value = updated;
  }

  Future<bool> addComment({
    required String postId,
    required String comment,
  }) async {
    isPostingComment.value = true;
    try {
      final data = await _repo.addComment(postId: postId, comment: comment);
      if (data != null) {
        // Silent refresh so the comment list updates without tearing down the
        // video player (which would restart playback).
        await fetchDetail(postId, showLoader: false);
        return true;
      }
      return false;
    } finally {
      isPostingComment.value = false;
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final ok = await _repo.deleteComment(postId: postId, commentId: commentId);
    if (ok) await fetchDetail(postId, showLoader: false);
    return ok;
  }

  // ─── Admin actions ──────────────────────────────────────────

  Future<String?> createPost({
    required String title,
    String? content,
    required String mediaType,
    required String mediaPath,
  }) async {
    isSubmittingPost.value = true;
    try {
      final data = await _repo.createPost(
        title: title,
        content: content,
        mediaType: mediaType,
        mediaPath: mediaPath,
      );
      if (data == null) return null;
      await fetchFeed();
      return data['id']?.toString();
    } finally {
      isSubmittingPost.value = false;
    }
  }

  Future<bool> updatePost({
    required String postId,
    String? title,
    String? content,
    String? mediaPath,
  }) async {
    isSubmittingPost.value = true;
    try {
      final data = await _repo.updatePost(
        postId: postId,
        title: title,
        content: content,
        mediaPath: mediaPath,
      );
      if (data == null) return false;
      await fetchFeed();
      if (selectedPost.value?.id == postId) await fetchDetail(postId);
      return true;
    } finally {
      isSubmittingPost.value = false;
    }
  }

  Future<bool> deletePost(String postId) async {
    isDeletingPost.value = true;
    try {
      final ok = await _repo.deletePost(postId);
      if (ok) {
        posts.removeWhere((p) => p.id == postId);
        if (selectedPost.value?.id == postId) selectedPost.value = null;
      }
      return ok;
    } finally {
      isDeletingPost.value = false;
    }
  }
}
