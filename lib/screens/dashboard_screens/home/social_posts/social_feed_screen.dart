import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/controllers/social_post_controller.dart';
import 'package:supergithr/models/social_post_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/social_posts/create_social_post_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/social_posts/social_post_detail_screen.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/social_video_player.dart';
import 'package:supergithr/views/text_styles.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final SocialPostController c = Get.find<SocialPostController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.posts.isEmpty) c.fetchFeed();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      c.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              _header(),
              Expanded(
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () => c.fetchFeed(),
                  child: Obx(() {
                    if (c.isLoadingFeed.value && c.posts.isEmpty) {
                      return _buildShimmer();
                    }
                    if (c.posts.isEmpty) return _buildEmpty();
                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 120),
                      itemCount: c.posts.length + 1,
                      itemBuilder: (_, i) {
                        if (i == c.posts.length) return _buildFooter();
                        return _PostCard(
                          post: c.posts[i],
                          onTap: () => _openDetail(c.posts[i]),
                          onLike: () => c.toggleLike(c.posts[i]),
                          onCommentTap: () => _openDetail(c.posts[i]),
                        ).animate().fadeIn(
                              duration: 320.ms,
                              delay: (i * 40).ms,
                            );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      // Only admins / HR can create posts.
      floatingActionButton: Obx(
        () => c.isAdmin.value
            ? Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: FloatingActionButton.extended(
                  backgroundColor: kPrimaryColor,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    "New Post",
                    style: textStyleMontserratBold(
                        fontSize: 14, color: Colors.white),
                  ),
                  onPressed: () => Get.to(() => const CreateSocialPostScreen()),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dynamic_feed_rounded,
                color: kPrimaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Social Feed",
                  style: textStyleMontserratBold(
                    fontSize: 20,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                Text(
                  "Stay connected with your team",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => IconButton(
              onPressed:
                  c.isLoadingFeed.value ? null : () => c.fetchFeed(),
              icon: Icon(Icons.refresh_rounded,
                  color:
                      c.isLoadingFeed.value ? Colors.grey : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dynamic_feed_outlined,
              color: kPrimaryColor,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            "No posts yet",
            style: textStyleMontserratBold(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            "Be the first to share something with the team",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 120),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media (16:9, matches _PostMedia)
                ClipRRect(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: _bar(width: 180, height: 14),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: _bar(width: double.infinity, height: 10),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 60, 0),
                  child: _bar(width: double.infinity, height: 10),
                ),
                // Action row (like + comment)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Row(
                    children: [
                      _bar(width: 60, height: 16),
                      const SizedBox(width: 16),
                      _bar(width: 80, height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildFooter() {
    return Obx(() {
      if (c.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
              child: CircularProgressIndicator(color: kPrimaryColor)),
        );
      }
      if (!c.hasMore && c.posts.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              "You're all caught up",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
      return const SizedBox(height: 16);
    });
  }

  Future<void> _openDetail(SocialPost post) async {
    await Get.to(() => SocialPostDetailScreen(postId: post.id));
  }
}

// ─── Post Card ───────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onCommentTap;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostMedia(post: post),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: textStyleMontserratBold(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        _relativeTime(post.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  _ActionButton(
                    icon: post.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: post.isLiked ? Colors.red : Colors.grey.shade700,
                    label: "${post.likesCount}",
                    onTap: onLike,
                  ),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    color: Colors.grey.shade700,
                    label: "Comment",
                    onTap: onCommentTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final now = DateTime.now();
    final d = now.difference(t.toLocal());
    if (d.inMinutes < 1) return "now";
    if (d.inMinutes < 60) return "${d.inMinutes}m";
    if (d.inHours < 24) return "${d.inHours}h";
    if (d.inDays < 7) return "${d.inDays}d";
    return DateFormat('MMM d').format(t.toLocal());
  }
}

class _PostMedia extends StatelessWidget {
  final SocialPost post;
  const _PostMedia({required this.post});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Shorter landscape area instead of a full square.
      aspectRatio: 16 / 9,
      child: post.isVideo ? _videoPlaceholder() : _image(),
    );
  }

  Widget _image() {
    return CachedNetworkImage(
      imageUrl: post.mediaUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined,
            color: Colors.grey, size: 36),
      ),
    );
  }

  Widget _videoPlaceholder() {
    // Shows the video's first frame as the thumbnail with a play overlay.
    // Tapping the card opens the detail where it plays in-app.
    return VideoThumbnail(url: post.mediaUrl);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
