import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';

/// Product carousels from `GET /api/feeds/home`.
class HomeFeeds {
  const HomeFeeds({
    this.topPicks = const [],
    this.offers = const [],
    this.trending = const [],
  });

  final List<CommerceProduct> topPicks;
  final List<CommerceProduct> offers;
  final List<CommerceProduct> trending;

  factory HomeFeeds.fromJson(Map<String, dynamic> json) {
    List<CommerceProduct> parse(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) =>
                CommerceProduct.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return HomeFeeds(
      topPicks: parse('top_picks'),
      offers: parse('offers'),
      trending: parse('trending'),
    );
  }
}
