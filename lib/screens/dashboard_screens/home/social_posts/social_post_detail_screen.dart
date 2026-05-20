import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/social_post_controller.dart';
import 'package:supergithr/models/social_post_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/social_posts/create_social_post_screen.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/social_video_player.dart';
import 'package:supergithr/views/text_styles.dart';

class SocialPostDetailScreen extends StatefulWidget {
  final String postId;
  const SocialPostDetailScreen({super.key, required this.postId});

  @override
  State<SocialPostDetailScreen> createState() => _SocialPostDetailScreenState();
}

class _SocialPostDetailScreenState extends State<SocialPostDetailScreen> {
  final SocialPostController c = Get.find<SocialPostController>();
  final TextEditingController _commentCtrl = TextEditingController();
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.fetchDetail(widget.postId);
    });
  }

  Future<void> _loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _employeeId = prefs.getString('employee_id'));
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: "Post"),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (c.isLoadingDetail.value && c.selectedPost.value == null) {
                  return _buildDetailShimmer();
                }
                final post = c.selectedPost.value;
                if (post == null) {
                  return Center(
                    child: Text(
                      "Post not found",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return Column(
                  children: [
                    // Pinned media — full width, doesn't scroll.
                    _buildMedia(post),
                    Expanded(
                      child: RefreshIndicator(
                        color: kPrimaryColor,
                        onRefresh: () => c.fetchDetail(widget.postId),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 14, bottom: 24),
                          children: [
                            _buildInfoSection(post),
                            const SizedBox(height: 18),
                            // _commentsHeader(post.comments.length),
                            const SizedBox(height: 8),
                            if (post.comments.isEmpty)
                              _emptyCommentState()
                            else
                              ...post.comments.map(
                                (cm) => _CommentTile(
                                  comment: cm,
                                  isOwn:
                                      _employeeId != null &&
                                      cm.employeeId == _employeeId,
                                  onDelete: () => _confirmDeleteComment(cm.id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            _commentInput(),
          ],
        ),
      ),
    );
  }

  /// Shimmer matching the detail layout: pinned media + info + comments.
  Widget _buildDetailShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media (16:9, full width like the real player)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 200, height: 16), // title
                const SizedBox(height: 10),
                _bar(width: 120, height: 10), // date
                const SizedBox(height: 14),
                _bar(width: double.infinity, height: 10), // content
                const SizedBox(height: 8),
                _bar(width: double.infinity, height: 10),
                const SizedBox(height: 8),
                _bar(width: 160, height: 10),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _bar(width: 60, height: 16),
                    const SizedBox(width: 16),
                    _bar(width: 90, height: 16),
                  ],
                ),
                const SizedBox(height: 24),
                // Comment rows
                ...List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bar(width: 110, height: 11),
                              const SizedBox(height: 8),
                              _bar(width: double.infinity, height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  /// Full-width pinned media (video or image) with a small bottom radius.
  Widget _buildMedia(SocialPost post) {
    return ClipRRect(
      child:
          post.isVideo
              // In-app player, auto-plays when the post is opened.
              ? SocialVideoPlayer(
                key: ValueKey('video_${post.id}'),
                url: post.mediaUrl,
                autoPlay: true,
              )
              : AspectRatio(
                // Shorter landscape box instead of a tall square.
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.mediaUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(color: Colors.grey.shade200),
                  errorWidget:
                      (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                          size: 36,
                        ),
                      ),
                ),
              ),
    );
  }

  /// Scrollable info: title, date, content, likes/comments counts.
  Widget _buildInfoSection(SocialPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: textStyleMontserratBold(
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
              // _adminMenu(post),
            ],
          ),
          if (post.createdAt != null)
            Text(
              DateFormat(
                'MMM d, yyyy · hh:mm a',
              ).format(post.createdAt!.toLocal()),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.45,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => c.toggleLike(post),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: post.isLiked ? Colors.red : Colors.grey.shade700,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${post.likesCount} likes",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              post.isLiked ? Colors.red : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.mode_comment_outlined,
                size: 20,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                "${post.comments.length} comments",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adminMenu(SocialPost post) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) async {
        if (v == 'edit') {
          await Get.to(() => CreateSocialPostScreen(existing: post));
        } else if (v == 'delete') {
          _confirmDeletePost(post.id);
        }
      },
      itemBuilder:
          (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: kPrimaryColor),
                  SizedBox(width: 8),
                  Text("Edit"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Delete"),
                ],
              ),
            ),
          ],
    );
  }

  Widget _commentsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.chat_bubble_outline_rounded,
          size: 18,
          color: kPrimaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          "Comments ($count)",
          style: textStyleMontserratBold(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _emptyCommentState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            "Be the first to comment",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _commentCtrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: "Write a comment…",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Material(
                color: kPrimaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: c.isPostingComment.value ? null : _send,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child:
                        c.isPostingComment.value
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final ok = await c.addComment(postId: widget.postId, comment: text);
    if (ok) _commentCtrl.clear();
  }

  void _confirmDeleteComment(String commentId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete comment?"),
        content: const Text("This action can't be undone."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await c.deleteComment(
                postId: widget.postId,
                commentId: commentId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePost(String postId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete post?"),
        content: const Text("This action can't be undone."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final ok = await c.deletePost(postId);
              if (ok) Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final SocialComment comment;
  final bool isOwn;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initial = comment.employee?.initial ?? '?';
    final name = comment.employee?.fullName ?? "Employee";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kPrimaryColor.withOpacity(0.15),
            child: Text(
              initial.toUpperCase(),
              style: textStyleMontserratBold(
                fontSize: 13,
                color: kPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: textStyleMontserratBold(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (comment.createdAt != null)
                      Text(
                        _short(comment.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    if (isOwn) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(DateTime t) {
    final now = DateTime.now();
    final d = now.difference(t.toLocal());
    if (d.inMinutes < 1) return "now";
    if (d.inMinutes < 60) return "${d.inMinutes}m";
    if (d.inHours < 24) return "${d.inHours}h";
    if (d.inDays < 7) return "${d.inDays}d";
    return DateFormat('MMM d').format(t.toLocal());
  }
}
