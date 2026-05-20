class SocialPost {
  final String id;
  final String? tenantId;
  final String title;
  final String content;
  final String mediaUrl;
  final String mediaType; // "image" | "video"
  final String? createdBy;
  final DateTime? createdAt;
  final int likesCount;
  final bool isLiked;
  final List<SocialComment> comments;

  SocialPost({
    required this.id,
    this.tenantId,
    required this.title,
    required this.content,
    required this.mediaUrl,
    required this.mediaType,
    this.createdBy,
    this.createdAt,
    required this.likesCount,
    required this.isLiked,
    this.comments = const [],
  });

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    final commentsRaw = map['comments'];
    final comments = (commentsRaw is List)
        ? commentsRaw
            .map((e) => SocialComment.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <SocialComment>[];
    return SocialPost(
      id: map['id']?.toString() ?? '',
      tenantId: map['tenant_id']?.toString(),
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      mediaUrl: map['media_url']?.toString() ?? '',
      mediaType: map['media_type']?.toString() ?? 'image',
      createdBy: map['created_by']?.toString(),
      createdAt: parseDate(map['created_at']),
      likesCount: (map['likes_count'] is num)
          ? (map['likes_count'] as num).toInt()
          : int.tryParse('${map['likes_count']}') ?? 0,
      isLiked: map['is_liked'] == true,
      comments: comments,
    );
  }

  bool get isImage => mediaType.toLowerCase() == 'image';
  bool get isVideo => mediaType.toLowerCase() == 'video';

  SocialPost copyWith({
    int? likesCount,
    bool? isLiked,
    List<SocialComment>? comments,
    String? title,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) {
    return SocialPost(
      id: id,
      tenantId: tenantId,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdBy: createdBy,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }
}

class SocialComment {
  final String id;
  final String postId;
  final String employeeId;
  final String comment;
  final DateTime? createdAt;
  final SocialCommentEmployee? employee;

  SocialComment({
    required this.id,
    required this.postId,
    required this.employeeId,
    required this.comment,
    this.createdAt,
    this.employee,
  });

  factory SocialComment.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
    return SocialComment(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      employeeId: map['employee_id']?.toString() ?? '',
      comment: map['comment']?.toString() ?? '',
      createdAt: parseDate(map['created_at']),
      employee: map['employee'] is Map
          ? SocialCommentEmployee.fromMap(
              Map<String, dynamic>.from(map['employee']))
          : null,
    );
  }
}

class SocialCommentEmployee {
  final String id;
  final String? firstName;
  final String? lastName;

  SocialCommentEmployee({
    required this.id,
    this.firstName,
    this.lastName,
  });

  factory SocialCommentEmployee.fromMap(Map<String, dynamic> map) {
    return SocialCommentEmployee(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
    );
  }

  String get fullName {
    final f = firstName?.trim() ?? '';
    final l = lastName?.trim() ?? '';
    final s = "$f $l".trim();
    return s.isEmpty ? "Employee" : s;
  }

  String get initial =>
      (firstName?.trim().isNotEmpty == true) ? firstName!.trim()[0] : '?';
}
