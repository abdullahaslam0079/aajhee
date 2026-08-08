import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';

class OfferSearchPage {
  const OfferSearchPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final List<OfferModel> results;

  bool get hasMore => page * pageSize < count;

  factory OfferSearchPage.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return OfferSearchPage(
      count: parseApiInt(json['count']),
      page: parseApiInt(json['page'], fallback: 1),
      pageSize: parseApiInt(json['page_size'], fallback: 20),
      results: rawResults
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static const empty = OfferSearchPage(
    count: 0,
    page: 1,
    pageSize: 20,
    results: [],
  );
}
