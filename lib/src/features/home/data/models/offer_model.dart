import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';
import 'package:goluto/src/utils/media_url_utils.dart';

enum OfferType {
  percentageBill('percentage_bill'),
  item('item'),
  deal('deal');

  const OfferType(this.apiValue);

  final String apiValue;

  static OfferType fromApi(String value) {
    return OfferType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => OfferType.percentageBill,
    );
  }

  String get typeBadgeLabel => switch (this) {
        item => 'Item deal',
        deal => 'Deal',
        percentageBill => 'Flat off',
      };

  String get viewOnlyActionLabel => switch (this) {
        deal => 'View Deal',
        _ => 'View Offer',
      };

  String get defaultExternalUrlLabel => viewOnlyActionLabel;
}

enum OfferRedemptionMode {
  scannable('scannable'),
  viewOnly('view_only');

  const OfferRedemptionMode(this.apiValue);

  final String apiValue;

  static OfferRedemptionMode fromApi(String? value) {
    if (value == viewOnly.apiValue) return viewOnly;
    return scannable;
  }

  bool get isViewOnly => this == viewOnly;
}

/// Where an offer can be redeemed: all channels, online-only, or in-store-only.
enum OfferChannelFilter {
  all,
  online,
  inStore;

  String get label => switch (this) {
        all => 'All',
        online => 'Online',
        inStore => 'In-store',
      };

  bool matches(OfferModel offer) => switch (this) {
        all => true,
        online => offer.isAvailableOnline,
        inStore => offer.isAvailableInStore,
      };
}

class OfferModel {
  const OfferModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.categoryId,
    required this.categoryName,
    required this.category,
    required this.branchIds,
    required this.offerType,
    required this.redemptionMode,
    this.isOnline = false,
    this.isInStore = true,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.externalUrl,
    required this.externalUrlLabel,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.discountPercent,
    required this.itemName,
    this.includedItems = const [],
    required this.originalPrice,
    required this.discountedPrice,
    required this.usageLimitType,
    required this.usageLimitCount,
    required this.isEnabled,
    required this.isTimeLimited,
    required this.startsAt,
    required this.endsAt,
    required this.qrCode,
    required this.isActive,
    this.userRedemptionCount,
    this.userRemainingUses,
    this.isAvailableForUser,
    this.lastRedeemedAt,
    this.periodResetsAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.businessViewCount = 0,
    this.businessLikeCount = 0,
    this.isBusinessLiked = false,
    this.businessLogoUrl,
    this.featuredBranchId,
    this.featuredBranchName,
    this.nearestDistanceKm,
  });

  final int id;
  final int businessId;
  final String businessName;
  final int categoryId;
  final String categoryName;
  final CategoryModel category;
  final List<int> branchIds;
  final OfferType offerType;
  final OfferRedemptionMode redemptionMode;
  final bool isOnline;
  final bool isInStore;
  final String title;
  final String description;
  final String detailedDescription;
  final String? externalUrl;
  final String? externalUrlLabel;
  final String? imageUrl;
  final List<String> imageUrls;
  final double discountPercent;
  final String itemName;
  final List<String> includedItems;
  final double? originalPrice;
  final double? discountedPrice;
  final String usageLimitType;
  final int usageLimitCount;
  final bool isEnabled;
  final bool isTimeLimited;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String qrCode;
  final bool isActive;
  final int? userRedemptionCount;
  final int? userRemainingUses;
  final bool? isAvailableForUser;
  final DateTime? lastRedeemedAt;
  final DateTime? periodResetsAt;
  final int viewCount;
  final int likeCount;
  final bool isLiked;
  final int businessViewCount;
  final int businessLikeCount;
  final bool isBusinessLiked;
  final String? businessLogoUrl;
  final int? featuredBranchId;
  final String? featuredBranchName;
  final double? nearestDistanceKm;

  String get subtitle {
    if (description.trim().isNotEmpty) return description.trim();
    if (offerType == OfferType.deal && includedItems.isNotEmpty) {
      return includedItems.join(' · ');
    }
    if (itemName.trim().isNotEmpty) return itemName.trim();
    if (offerType == OfferType.percentageBill) {
      return 'On the entire bill';
    }
    return '';
  }

  String get typeBadgeLabel => offerType.typeBadgeLabel;

  String get viewOnlyActionLabel => offerType.viewOnlyActionLabel;

  bool get isDealOffer => offerType == OfferType.deal;

  /// Thumbnail callout: DEAL for combo deals, otherwise % OFF when set.
  String? get promoBadgeLabel {
    if (isDealOffer) return 'DEAL';
    if (discountPercent > 0) {
      return '${discountPercent.toStringAsFixed(0)}% OFF';
    }
    return null;
  }

  bool get hasCompareAtPrice =>
      originalPrice != null && discountedPrice != null;

  bool get hasPromoPrice => discountedPrice != null;

  String get detailText {
    if (hasCompareAtPrice) {
      return 'Instead of €${originalPrice!.toStringAsFixed(2)}';
    }
    if (isTimeLimited && endsAt != null) {
      return 'Valid until ${_formatDate(endsAt!)}';
    }
    return '';
  }

  bool get isViewOnlyOffer => redemptionMode.isViewOnly;

  bool get isAvailableOnline => isOnline;

  bool get isAvailableInStore => isInStore;

  bool get isOnlineOnly => isOnline && !isInStore;

  bool get isInStoreOnly => isInStore && !isOnline;

  bool get isHybridChannel => isOnline && isInStore;

  /// Full label for details: Online only, In-store only, or Online & In-store.
  String get channelLabel {
    if (isHybridChannel) return 'Online & In-store';
    if (isOnlineOnly) return 'Online only';
    return 'In-store only';
  }

  /// Compact label for cards and image badges.
  String get channelShortLabel {
    if (isHybridChannel) return 'Both';
    if (isOnlineOnly) return 'Online';
    return 'In-store';
  }

  String? get resolvedExternalUrl {
    final url = externalUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  String externalLinkButtonLabel(String storeName) {
    final custom = externalUrlLabel?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return offerType.defaultExternalUrlLabel;
  }

  String get summaryText {
    final short = description.trim();
    if (short.isNotEmpty) return short;
    return subtitle;
  }

  String get fullDetailsText {
    final detailed = detailedDescription.trim();
    if (detailed.isNotEmpty) return detailed;
    return summaryText;
  }

  List<String> get displayImageUrls {
    if (imageUrls.isNotEmpty) return imageUrls;
    final primary = imageUrl?.trim();
    if (primary != null && primary.isNotEmpty) return [primary];
    return const [];
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = _parseImageUrls(json['image_urls']);
    final branchIds = _parseBranchIds(json);
    final featuredBranchId = _parseFeaturedBranchId(json['featured_branch']);
    final isOnline = parseApiBool(json['is_online']);
    return OfferModel(
      id: parseApiInt(json['id']),
      businessId: parseApiInt(json['business_id']),
      businessName: parseApiString(json['business_name']) ?? '',
      categoryId: parseApiInt(json['category_id']),
      categoryName: parseApiString(json['category_name']) ?? '',
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      branchIds: branchIds,
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      redemptionMode: OfferRedemptionMode.fromApi(
        parseApiString(json['redemption_mode']),
      ),
      isOnline: isOnline,
      isInStore: _resolveIsInStore(
        json,
        isOnline: isOnline,
        branchIds: branchIds,
        featuredBranchId: featuredBranchId,
      ),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      detailedDescription: parseApiString(json['detailed_description']) ?? '',
      externalUrl: parseApiString(json['external_url']),
      externalUrlLabel: parseApiString(json['external_url_label']),
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])) ??
          (imageUrls.isNotEmpty ? imageUrls.first : null),
      imageUrls: imageUrls,
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      includedItems: _parseIncludedItems(json['included_items']),
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
      usageLimitType: parseApiString(json['usage_limit_type']) ?? '',
      usageLimitCount: parseApiInt(json['usage_limit_count']),
      isEnabled: json['is_enabled'] as bool? ?? true,
      isTimeLimited: json['is_time_limited'] as bool? ?? false,
      startsAt: _parseNullableDate(json['starts_at']),
      endsAt: _parseNullableDate(json['ends_at']),
      qrCode: parseApiString(json['qr_code']) ?? '',
      isActive: json['is_active'] as bool? ?? true,
      userRedemptionCount: _parseNullableInt(
        json['user_redemption_count'] ??
            json['redemption_count'] ??
            json['times_redeemed'] ??
            json['user_redeem_count'],
      ),
      userRemainingUses: _parseNullableInt(
        json['user_remaining_uses'] ??
            json['remaining_uses'] ??
            json['remaining_count'],
      ),
      isAvailableForUser: json['is_available_for_user'] as bool? ??
          json['can_redeem'] as bool?,
      lastRedeemedAt: _parseNullableDate(json['last_redeemed_at']),
      periodResetsAt: _parseNullableDate(json['period_resets_at']),
      viewCount: parseApiInt(json['view_count']),
      likeCount: parseApiInt(json['like_count']),
      isLiked: json['is_liked'] as bool? ?? false,
      businessViewCount: parseApiInt(json['business_view_count']),
      businessLikeCount: parseApiInt(json['business_like_count']),
      isBusinessLiked: json['is_business_liked'] as bool? ?? false,
      businessLogoUrl: _parseBusinessLogoUrl(json),
      featuredBranchId: featuredBranchId,
      featuredBranchName: _parseFeaturedBranchName(json['featured_branch']),
      nearestDistanceKm: parseApiNullableDouble(json['nearest_distance_km']),
    );
  }

  static List<int> _parseBranchIds(Map<String, dynamic> json) {
    final raw = json['branch_ids'] ?? json['branches'];
    if (raw is List) {
      final ids = <int>[];
      for (final item in raw) {
        final id = item is Map
            ? parseApiInt(item['id'])
            : parseApiInt(item);
        if (id > 0) ids.add(id);
      }
      return ids;
    }

    final single = json['branch_id'];
    if (single != null) {
      final id = parseApiInt(single);
      if (id > 0) return [id];
    }
    return const [];
  }

  static bool _resolveIsInStore(
    Map<String, dynamic> json, {
    required bool isOnline,
    required List<int> branchIds,
    required int? featuredBranchId,
  }) {
    final explicit = parseApiNullableBool(
      json['is_in_store'] ??
          json['available_in_store'] ??
          json['in_store'],
    );
    if (explicit != null) return explicit;
    return !isOnline || branchIds.isNotEmpty || featuredBranchId != null;
  }

  static int? _parseFeaturedBranchId(dynamic branchJson) {
    if (branchJson == null) return null;
    if (branchJson is Map) {
      final id = parseApiInt(branchJson['id']);
      return id > 0 ? id : null;
    }
    final id = parseApiInt(branchJson);
    return id > 0 ? id : null;
  }

  static String? _parseFeaturedBranchName(dynamic branchJson) {
    if (branchJson is! Map<String, dynamic>) return null;
    return parseApiString(branchJson['name']);
  }

  static String? _parseBusinessLogoUrl(Map<String, dynamic> json) {
    String? fromValue(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return resolveMediaUrl(
          parseApiString(
            value['url'] ??
                value['logo_url'] ??
                value['logo'] ??
                value['image'],
          ),
        );
      }
      return resolveMediaUrl(parseApiString(value));
    }

    final direct = fromValue(
      json['business_logo_url'] ??
          json['business_logo'] ??
          json['logo_url'] ??
          json['logo'],
    );
    if (direct != null) return direct;

    final business = json['business'];
    if (business is Map) {
      final nested = fromValue(
        business['logo_url'] ??
            business['business_logo_url'] ??
            business['logo'] ??
            business['image'],
      );
      if (nested != null) return nested;
    }

    final featured = json['featured_branch'];
    if (featured is Map) {
      return fromValue(
        featured['business_logo_url'] ??
            featured['logo_url'] ??
            featured['logo'],
      );
    }
    return null;
  }

  static List<String> _parseIncludedItems(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => (item?.toString() ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _parseImageUrls(dynamic value) {
    if (value is! List<dynamic>) return const [];
    final urls = <String>[];
    for (final item in value) {
      final resolved = resolveMediaUrl(parseApiString(item));
      if (resolved != null && resolved.isNotEmpty) {
        urls.add(resolved);
      }
    }
    return urls;
  }

  OfferModel copyWithEngagement({
    int? viewCount,
    int? likeCount,
    bool? isLiked,
    int? businessLikeCount,
    bool? isBusinessLiked,
  }) {
    return OfferModel(
      id: id,
      businessId: businessId,
      businessName: businessName,
      categoryId: categoryId,
      categoryName: categoryName,
      category: category,
      branchIds: branchIds,
      offerType: offerType,
      redemptionMode: redemptionMode,
      isOnline: isOnline,
      isInStore: isInStore,
      title: title,
      description: description,
      detailedDescription: detailedDescription,
      externalUrl: externalUrl,
      externalUrlLabel: externalUrlLabel,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      discountPercent: discountPercent,
      itemName: itemName,
      includedItems: includedItems,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      usageLimitType: usageLimitType,
      usageLimitCount: usageLimitCount,
      isEnabled: isEnabled,
      isTimeLimited: isTimeLimited,
      startsAt: startsAt,
      endsAt: endsAt,
      qrCode: qrCode,
      isActive: isActive,
      userRedemptionCount: userRedemptionCount,
      userRemainingUses: userRemainingUses,
      isAvailableForUser: isAvailableForUser,
      lastRedeemedAt: lastRedeemedAt,
      periodResetsAt: periodResetsAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      businessViewCount: businessViewCount,
      businessLikeCount: businessLikeCount ?? this.businessLikeCount,
      isBusinessLiked: isBusinessLiked ?? this.isBusinessLiked,
      businessLogoUrl: businessLogoUrl,
      featuredBranchId: featuredBranchId,
      featuredBranchName: featuredBranchName,
      nearestDistanceKm: nearestDistanceKm,
    );
  }

  factory OfferModel.fromQrSummary(Map<String, dynamic> json) {
    final imageUrls = _parseImageUrls(json['image_urls']);
    final branchIds = _parseBranchIds(json);
    final featuredBranchId = _parseFeaturedBranchId(json['featured_branch']);
    final isOnline = parseApiBool(json['is_online']);
    return OfferModel(
      id: parseApiInt(json['id']),
      businessId: 0,
      businessName: parseApiString(json['business_name']) ?? '',
      categoryId: 0,
      categoryName: '',
      category: const CategoryModel(id: 0, name: ''),
      branchIds: branchIds,
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      redemptionMode: OfferRedemptionMode.fromApi(
        parseApiString(json['redemption_mode']),
      ),
      isOnline: isOnline,
      isInStore: _resolveIsInStore(
        json,
        isOnline: isOnline,
        branchIds: branchIds,
        featuredBranchId: featuredBranchId,
      ),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      detailedDescription: parseApiString(json['detailed_description']) ?? '',
      externalUrl: parseApiString(json['external_url']),
      externalUrlLabel: parseApiString(json['external_url_label']),
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])) ??
          (imageUrls.isNotEmpty ? imageUrls.first : null),
      imageUrls: imageUrls,
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      includedItems: _parseIncludedItems(json['included_items']),
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
      businessLogoUrl: _parseBusinessLogoUrl(json),
      usageLimitType: '',
      usageLimitCount: 1,
      isEnabled: json['is_enabled'] as bool? ?? true,
      isTimeLimited: false,
      startsAt: null,
      endsAt: null,
      qrCode: '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    return DateTime.tryParse(parseApiString(value) ?? '');
  }
}
