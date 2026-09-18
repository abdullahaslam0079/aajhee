import 'package:aajhee/src/utils/api_value_parsers.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  int? get businessId => _asInt(data['business_id']);
  int? get branchId => _asInt(data['branch_id']);
  int? get offerId => _asInt(data['offer_id']);

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AppNotification(
      id: parseApiInt(json['id']),
      type: parseApiString(json['type']) ?? 'generic',
      title: parseApiString(json['title']) ?? '',
      body: parseApiString(json['body']) ?? '',
      data: data is Map<String, dynamic>
          ? data
          : <String, dynamic>{},
      isRead: json['is_read'] as bool? ?? json['read_at'] != null,
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class NotificationPage {
  const NotificationPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final List<AppNotification> results;

  bool get hasMore => page * pageSize < count;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final raw = json['results'] as List<dynamic>? ?? const [];
    return NotificationPage(
      count: parseApiInt(json['count']),
      page: parseApiInt(json['page'], fallback: 1),
      pageSize: parseApiInt(json['page_size'], fallback: 20),
      results: raw
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static const empty = NotificationPage(
    count: 0,
    page: 1,
    pageSize: 20,
    results: [],
  );
}
