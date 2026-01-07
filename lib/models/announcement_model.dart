class AnnouncementModel {
  String? message;
  List<AnnouncementData>? data;

  AnnouncementModel({this.message, this.data});

  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <AnnouncementData>[];
      json['data'].forEach((v) {
        data!.add(AnnouncementData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AnnouncementData {
  String? id;
  String? title;
  String? message;
  String? type;
  String? priority;
  String? publishAt;
  String? expiresAt;
  String? status;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  AnnouncementData({
    this.id,
    this.title,
    this.message,
    this.type,
    this.priority,
    this.publishAt,
    this.expiresAt,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  AnnouncementData.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    priority = json['priority'];
    publishAt = json['publish_at'];
    expiresAt = json['expires_at'];
    status = json['status'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ID'] = id;
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['priority'] = priority;
    data['publish_at'] = publishAt;
    data['expires_at'] = expiresAt;
    data['status'] = status;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
