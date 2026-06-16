import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:video_player/video_player.dart';

/// A lightweight video poster: initializes the video, holds it on the first
/// frame (no playback) so the feed shows the video's image inside the box,
/// with a play overlay. Tapping is handled by the parent (opens the detail).
class VideoThumbnail extends StatefulWidget {
  final String url;
  const VideoThumbnail({super.key, required this.url});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = c;
      await c.initialize();
      await c.seekTo(Duration.zero);
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black87),
        if (_ready && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        if (_error)
          const Center(
            child: Icon(Icons.videocam_off_rounded,
                color: Colors.white54, size: 36),
          ),
        // Play overlay
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: kPrimaryColor, size: 34),
          ),
        ),
        // "Video" badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(TranslationKeys.video.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// In-app video player for social posts. Plays a network video with standard
/// controls (play/pause, scrubber, fullscreen) inside the app — no external
/// launch. [autoPlay] starts playback immediately (used on the detail screen).
class SocialVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;

  const SocialVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<SocialVideoPlayer> createState() => _SocialVideoPlayerState();
}

class _SocialVideoPlayerState extends State<SocialVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  // Fixed display ratio so the player height stays identical while loading
  // and after playback starts (the video letterboxes inside this box).
  static const double _displayAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      _videoController = controller;
      await controller.initialize();
      if (!mounted) return;
      final ratio = controller.value.aspectRatio;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        // Keep the video's true ratio so it isn't distorted; it's letterboxed
        // within the fixed-height box.
        aspectRatio: (ratio.isFinite && ratio > 0) ? ratio : _displayAspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: kPrimaryColor,
          handleColor: kPrimaryColor,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: Colors.black),
      );
      setState(() {});
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Constant aspect ratio → constant height across loading and playing.
    return AspectRatio(
      aspectRatio: _displayAspectRatio,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.videocam_off_rounded,
            color: Colors.white54, size: 40),
      );
    }

    final chewie = _chewieController;
    if (chewie == null || !chewie.videoPlayerController.value.isInitialized) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(controller: chewie),
    );
  }
}
