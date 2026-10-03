import 'package:aajhee/src/utils/api_value_parsers.dart';

/// Shop meta from `GET /api/stores/.../header`.
class StoreHeader {
  const StoreHeader({
    required this.business,
    required this.contacts,
    required this.deliveryOptions,
    this.branch,
  });

  final StoreBusinessInfo business;
  final StoreBranchInfo? branch;
  final List<StoreContact> contacts;
  final List<Map<String, dynamic>> deliveryOptions;

  factory StoreHeader.fromJson(Map<String, dynamic> json) {
    return StoreHeader(
      business: StoreBusinessInfo.fromJson(
        Map<String, dynamic>.from(json['business'] as Map? ?? const {}),
      ),
      branch: json['branch'] is Map
          ? StoreBranchInfo.fromJson(
              Map<String, dynamic>.from(json['branch'] as Map),
            )
          : null,
      contacts: (json['contacts'] as List? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) => StoreContact.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      deliveryOptions: (json['delivery_options'] as List? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }
}

class StoreBusinessInfo {
  const StoreBusinessInfo({
    required this.id,
    required this.name,
    required this.showOnline,
    required this.showInStore,
    required this.isVerified,
    required this.ratingAvg,
    required this.ratingCount,
    this.logoUrl,
    this.businessHours,
    this.presenceMode,
    this.onlineCoverage,
  });

  final int id;
  final String name;
  final bool showOnline;
  final bool showInStore;
  final bool isVerified;
  final String ratingAvg;
  final int ratingCount;
  final String? logoUrl;
  final dynamic businessHours;
  final String? presenceMode;
  final String? onlineCoverage;

  factory StoreBusinessInfo.fromJson(Map<String, dynamic> json) {
    final verified = json['is_verified'] == true ||
        json['verified'] == true ||
        (json['verification_status']?.toString() == 'verified');
    return StoreBusinessInfo(
      id: parseApiInt(json['id']),
      name: parseApiString(json['name']) ?? '',
      showOnline: json['show_online'] == true,
      showInStore: json['show_instore'] == true,
      isVerified: verified,
      ratingAvg: json['rating_avg']?.toString() ?? '0.00',
      ratingCount: parseApiInt(json['rating_count']),
      logoUrl: parseApiString(json['logo_url']),
      businessHours: json['business_hours'],
      presenceMode: parseApiString(json['presence_mode']),
      onlineCoverage: parseApiString(json['online_coverage']),
    );
  }
}

class StoreBranchInfo {
  const StoreBranchInfo({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.ratingAvg,
    required this.ratingCount,
    this.city,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String formattedAddress;
  final String ratingAvg;
  final int ratingCount;
  final String? city;
  final double? latitude;
  final double? longitude;

  factory StoreBranchInfo.fromJson(Map<String, dynamic> json) {
    return StoreBranchInfo(
      id: parseApiInt(json['id']),
      name: parseApiString(json['name']) ?? '',
      formattedAddress: parseApiString(json['formatted_address']) ??
          parseApiString(json['formattedAddress']) ??
          '',
      ratingAvg: json['rating_avg']?.toString() ?? '0.00',
      ratingCount: parseApiInt(json['rating_count']),
      city: parseApiString(json['city']),
      latitude: parseApiNullableDouble(json['latitude']),
      longitude: parseApiNullableDouble(json['longitude']),
    );
  }
}

class StoreContact {
  const StoreContact({
    required this.contactType,
    required this.value,
    this.id,
    this.isPrimary = false,
  });

  final int? id;
  final String contactType;
  final String value;
  final bool isPrimary;

  factory StoreContact.fromJson(Map<String, dynamic> json) {
    return StoreContact(
      id: parseApiNullableInt(json['id']),
      contactType:
          (json['contact_type']?.toString() ?? '').trim().toLowerCase(),
      value: json['value']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'contact_type': contactType,
        'value': value,
        'is_primary': isPrimary,
      };
}
