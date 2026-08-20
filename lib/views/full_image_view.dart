import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom view of a network image (e.g. profile avatar).
class FullImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullImageViewScreen({
    super.key,
    required this.imageUrl,
    this.heroTag = 'full_image',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            maxScale: 5.0,
            minScale: 0.5,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 60,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
