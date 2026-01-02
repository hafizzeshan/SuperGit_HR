import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String? filePath;

  const DocumentViewerScreen({super.key, required this.filePath});

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final path = filePath ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: Center(
        child:
            path.isEmpty
                ? const Text('No document available')
                : Builder(
                  builder: (context) {
                    // Network / remote image
                    if (path.startsWith('http') && _isImage(path)) {
                      return InteractiveViewer(
                        child: Image.network(
                          path,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Failed to load image'),
                              ),
                        ),
                      );
                    }

                    // Local file image
                    if (!kIsWeb && File(path).existsSync() && _isImage(path)) {
                      return InteractiveViewer(
                        child: Image.file(File(path), fit: BoxFit.contain),
                      );
                    }

                    // Fallback: try to open in external browser (works for pdfs and other URLs)
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            size: 72,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            path,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(path);
                              if (uri != null) {
                                if (!await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not open document'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid document URL'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open Document'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
