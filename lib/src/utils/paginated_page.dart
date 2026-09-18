import 'package:aajhee/src/utils/api_value_parsers.dart';

class PaginatedPage<T> {
  const PaginatedPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final List<T> results;

  bool get hasMore => page * pageSize < count;

  factory PaginatedPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parseItem,
  ) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return PaginatedPage<T>(
      count: parseApiInt(json['count']),
      page: parseApiInt(json['page'], fallback: 1),
      pageSize: parseApiInt(json['page_size'], fallback: 20),
      results: rawResults
          .whereType<Map<Object?, Object?>>()
          .map((item) => parseItem(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  static PaginatedPage<T> empty<T>({int pageSize = 20}) => PaginatedPage<T>(
        count: 0,
        page: 1,
        pageSize: pageSize,
        results: const [],
      );
}
