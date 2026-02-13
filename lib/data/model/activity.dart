import 'package:yoshlar/data/model/officer.dart';

enum ActivityStatus { bajarilgan, rejalashtirilgan }

class ActivityImage {
  final int id;
  final String url;

  ActivityImage({required this.id, required this.url});

  factory ActivityImage.fromJson(Map<String, dynamic> json) {
    return ActivityImage(
      id: json['id'],
      url: json['url'] ?? '',
    );
  }
}

class Activity {
  final int? id;
  final int? youthId;
  final String? youthName;
  final OfficerModel? officer;
  final String title;
  final String description;
  final String result;
  final String date;
  final ActivityStatus status;
  final List<ActivityImage> images;
  final int commentsCount;
  final double? latitude;
  final double? longitude;
  final String? createdAt;

  Activity({
    this.id,
    this.youthId,
    this.youthName,
    this.officer,
    required this.title,
    required this.description,
    required this.result,
    required this.date,
    required this.status,
    this.images = const [],
    this.commentsCount = 0,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  String get dateWithTime {
    if (createdAt != null) {
      try {
        final dt = DateTime.parse(createdAt!).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        return '$date  $hour:$minute';
      } catch (_) {}
    }
    return date;
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final imagesData = json['images'] as List<dynamic>? ?? [];
    return Activity(
      id: json['id'],
      youthId: json['youthId'],
      youthName: json['youthName'],
      officer: json['officer'] != null
          ? OfficerModel.fromJson(json['officer'])
          : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      result: json['result'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] == 'bajarilgan'
          ? ActivityStatus.bajarilgan
          : ActivityStatus.rejalashtirilgan,
      images: imagesData
          .map((e) => ActivityImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      commentsCount: json['commentsCount'] ?? 0,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      createdAt: json['created_at'],
    );
  }
}
