import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/social_post_controller.dart';
import 'package:supergithr/models/social_post_model.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class CreateSocialPostScreen extends StatefulWidget {
  /// If non-null, screen runs in edit mode for the existing post.
  final SocialPost? existing;
  const CreateSocialPostScreen({super.key, this.existing});

  @override
  State<CreateSocialPostScreen> createState() => _CreateSocialPostScreenState();
}

class _CreateSocialPostScreenState extends State<CreateSocialPostScreen> {
  final SocialPostController c = Get.find<SocialPostController>();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();

  String _mediaType = 'image'; // image | video
  File? _picked;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _title.text = p.title;
      _content.text = p.content;
      _mediaType = p.isVideo ? 'video' : 'image';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: _mediaType == 'video' ? FileType.video : FileType.image,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    setState(() => _picked = File(path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _picked == null) {
      Utils.snackBar("Please select a media file", true);
      return;
    }

    if (_isEdit) {
      final ok = await c.updatePost(
        postId: widget.existing!.id,
        title: _title.text.trim(),
        content: _content.text.trim().isEmpty ? null : _content.text.trim(),
        mediaPath: _picked?.path,
      );
      if (ok) Get.back();
    } else {
      final id = await c.createPost(
        title: _title.text.trim(),
        content: _content.text.trim().isEmpty ? null : _content.text.trim(),
        mediaType: _mediaType,
        mediaPath: _picked!.path,
      );
      if (id != null) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: _isEdit ? "Edit Post" : "New Post"),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _sectionCard(
                icon: Icons.perm_media_rounded,
                title: "Media",
                subtitle:
                    _isEdit
                        ? "Replace the current image or video (optional)"
                        : "Pick an image or video to share",
                children: [
                  if (!_isEdit) ...[
                    _fieldLabel("Media Type"),
                    Row(
                      children: [
                        Expanded(
                          child: _typeChip(
                            label: "Image",
                            icon: Icons.image_outlined,
                            selected: _mediaType == 'image',
                            onTap: () {
                              setState(() {
                                _mediaType = 'image';
                                _picked = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeChip(
                            label: "Video",
                            icon: Icons.videocam_outlined,
                            selected: _mediaType == 'video',
                            onTap: () {
                              setState(() {
                                _mediaType = 'video';
                                _picked = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  _mediaPreview(),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                icon: Icons.title_rounded,
                title: "Post Details",
                subtitle: "Add a title and a short description",
                children: [
                  _fieldLabel("Title"),
                  _textField(
                    controller: _title,
                    icon: Icons.short_text_rounded,
                    hint: "What's the headline?",
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel("Description"),
                  _textField(
                    controller: _content,
                    icon: Icons.notes_rounded,
                    hint: "Optional content",
                    maxLines: 5,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: c.isSubmittingPost.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        c.isSubmittingPost.value
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isEdit
                                      ? Icons.save_rounded
                                      : Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEdit ? "Save Changes" : "Publish Post",
                                  style: textStyleMontserratBold(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Media preview ──────────────────────────────────────────

  Widget _mediaPreview() {
    final hasNew = _picked != null;
    final showExistingImage = _isEdit && !hasNew && widget.existing!.isImage;
    final showExistingVideo = _isEdit && !hasNew && widget.existing!.isVideo;

    return GestureDetector(
      onTap: _pickMedia,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              style:
                  hasNew || showExistingImage || showExistingVideo
                      ? BorderStyle.solid
                      : BorderStyle.solid,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasNew && _mediaType == 'image')
                Image.file(_picked!, fit: BoxFit.cover)
              else if (hasNew && _mediaType == 'video')
                _videoFilePreview(_picked!.path)
              else if (showExistingImage)
                CachedNetworkImage(
                  imageUrl: widget.existing!.mediaUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              else if (showExistingVideo)
                _videoUrlPreview(widget.existing!.mediaUrl)
              else
                _placeholder(),
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  color: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _pickMedia,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasNew || showExistingImage || showExistingVideo
                                ? Icons.swap_horiz_rounded
                                : Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasNew || showExistingImage || showExistingVideo
                                ? "Replace"
                                : "Pick",
                            style: textStyleMontserratBold(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _mediaType == 'video'
                  ? Icons.videocam_outlined
                  : Icons.image_outlined,
              color: kPrimaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _mediaType == 'video'
                ? "Tap to pick a video"
                : "Tap to pick an image",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoFilePreview(String path) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black87),
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: kPrimaryColor,
              size: 36,
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              path.split('/').last,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _videoUrlPreview(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black87),
        const Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            color: Colors.white,
            size: 60,
          ),
        ),
      ],
    );
  }

  // ─── UI helpers (matched with create_air_ticket style) ──────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyleMontserratBold(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        letterSpacing: 0.2,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
        prefixIcon:
            maxLines == 1
                ? Icon(icon, color: kPrimaryColor, size: 20)
                : Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Icon(icon, color: kPrimaryColor, size: 20),
                ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
        ),
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? kPrimaryColor.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey.shade200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? kPrimaryColor : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected ? kPrimaryColor : Colors.grey.shade800,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
