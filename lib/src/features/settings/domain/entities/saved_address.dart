import 'package:equatable/equatable.dart';

class SavedAddress extends Equatable {
  const SavedAddress({
    required this.id,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.isDefault = false,
  });

  final String id;
  final String street;
  final String houseNumber;
  final String postalCode;
  final String city;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final bool isDefault;

  String get line1 => '$street $houseNumber'.trim();

  String get line2 => '$postalCode $city'.trim();

  String get shortLabel {
    if (line1.isNotEmpty && line2.isNotEmpty) return '$line1, $line2';
    if (line1.isNotEmpty) return line1;
    if (line2.isNotEmpty) return line2;
    return formattedAddress;
  }

  SavedAddress copyWith({
    String? id,
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'street': street,
        'houseNumber': houseNumber,
        'postalCode': postalCode,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'formattedAddress': formattedAddress,
        'isDefault': isDefault,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      street: json['street'] as String,
      houseNumber: json['houseNumber'] as String,
      postalCode: json['postalCode'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      formattedAddress: json['formattedAddress'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        street,
        houseNumber,
        postalCode,
        city,
        latitude,
        longitude,
        formattedAddress,
        isDefault,
      ];
}
