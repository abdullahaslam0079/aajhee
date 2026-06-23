import 'package:equatable/equatable.dart';

class AddressSuggestion extends Equatable {
  const AddressSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String street;
  final String houseNumber;
  final String postalCode;
  final String city;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get shortLabel {
    if (subtitle != null && subtitle!.isNotEmpty) {
      return '$title, $subtitle';
    }
    return title;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        street,
        houseNumber,
        postalCode,
        city,
        latitude,
        longitude,
      ];
}
