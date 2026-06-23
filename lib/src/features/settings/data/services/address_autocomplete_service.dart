import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goluto/src/features/settings/domain/entities/address_suggestion.dart';

class AddressAutocompleteService {
  AddressAutocompleteService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _googleAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _googleDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  String get _googleApiKey => dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');

  Future<List<AddressSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    if (_googleApiKey.isNotEmpty) {
      try {
        return await _searchGoogle(trimmed);
      } catch (_) {
        return _searchNominatim(trimmed);
      }
    }

    return _searchNominatim(trimmed);
  }

  Future<AddressSuggestion> resolveSuggestion(AddressSuggestion suggestion) async {
    if (suggestion.hasFullDetails) return suggestion;

    if (_googleApiKey.isNotEmpty && !suggestion.id.startsWith('osm-')) {
      return _fetchGoogleDetails(suggestion);
    }

    return suggestion;
  }

  Future<List<AddressSuggestion>> _searchGoogle(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _googleAutocompleteUrl,
      queryParameters: {
        'input': query,
        'key': _googleApiKey,
        'types': 'address',
      },
    );

    final data = response.data;
    if (data == null || data['status'] != 'OK') return [];

    final predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions.map((prediction) {
      final map = prediction as Map<String, dynamic>;
      final structured = map['structured_formatting'] as Map<String, dynamic>?;
      final mainText = structured?['main_text'] as String? ??
          map['description'] as String? ??
          '';
      final secondaryText = _cleanSecondaryText(
        structured?['secondary_text'] as String?,
      );

      return AddressSuggestion(
        id: map['place_id'] as String,
        title: mainText,
        subtitle: secondaryText,
        street: '',
        houseNumber: '',
        postalCode: '',
        city: '',
      );
    }).toList();
  }

  Future<AddressSuggestion> _fetchGoogleDetails(
    AddressSuggestion suggestion,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _googleDetailsUrl,
      queryParameters: {
        'place_id': suggestion.id,
        'fields': 'address_component,geometry',
        'key': _googleApiKey,
      },
    );

    final data = response.data;
    if (data == null || data['status'] != 'OK') {
      throw Exception('Could not load address details');
    }

    final result = data['result'] as Map<String, dynamic>;
    final components = result['address_components'] as List<dynamic>? ?? [];
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    var streetNumber = '';
    var route = '';
    var postalCode = '';
    var city = '';

    for (final component in components) {
      final map = component as Map<String, dynamic>;
      final types = (map['types'] as List<dynamic>).cast<String>();
      final longName = map['long_name'] as String;

      if (types.contains('street_number')) {
        streetNumber = longName;
      } else if (types.contains('route')) {
        route = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('postal_town') && city.isEmpty) {
        city = longName;
      } else if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = longName;
      }
    }

    return _buildSuggestion(
      id: suggestion.id,
      street: route,
      houseNumber: streetNumber,
      postalCode: postalCode,
      city: city,
      latitude: (location?['lat'] as num?)?.toDouble(),
      longitude: (location?['lng'] as num?)?.toDouble(),
      fallbackTitle: suggestion.title,
      fallbackSubtitle: suggestion.subtitle,
    );
  }

  Future<List<AddressSuggestion>> _searchNominatim(String query) async {
    final response = await _dio.get<List<dynamic>>(
      _nominatimUrl,
      queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': 1,
        'limit': 8,
        'layer': 'address',
        'dedupe': 1,
      },
      options: Options(
        headers: {'User-Agent': 'GolutoApp/1.0'},
      ),
    );

    final results = response.data ?? [];
    return results
        .map((entry) {
          final map = entry as Map<String, dynamic>;
          final address = map['address'] as Map<String, dynamic>? ?? {};

          final street = _firstNonEmpty([
            address['road'],
            address['pedestrian'],
            address['footway'],
          ]);
          final houseNumber = _firstNonEmpty([address['house_number']]);
          final postalCode = _firstNonEmpty([address['postcode']]);
          final city = _firstNonEmpty([
            address['city'],
            address['town'],
            address['village'],
            address['municipality'],
          ]);

          return _buildSuggestion(
            id: 'osm-${map['place_id']}',
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            latitude: double.tryParse(map['lat']?.toString() ?? ''),
            longitude: double.tryParse(map['lon']?.toString() ?? ''),
          );
        })
        .where((s) => s.street.isNotEmpty || s.postalCode.isNotEmpty)
        .take(6)
        .toList();
  }

  AddressSuggestion _buildSuggestion({
    required String id,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    double? latitude,
    double? longitude,
    String? fallbackTitle,
    String? fallbackSubtitle,
  }) {
    final title = _buildTitle(street: street, houseNumber: houseNumber);
    final subtitle = _buildSubtitle(postalCode: postalCode, city: city);

    return AddressSuggestion(
      id: id,
      title: title.isNotEmpty ? title : (fallbackTitle ?? ''),
      subtitle: subtitle.isNotEmpty ? subtitle : fallbackSubtitle,
      street: street,
      houseNumber: houseNumber,
      postalCode: postalCode,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );
  }

  String _buildTitle({required String street, required String houseNumber}) {
    if (street.isEmpty && houseNumber.isEmpty) return '';
    if (street.isEmpty) return houseNumber;
    if (houseNumber.isEmpty) return street;
    return '$street $houseNumber';
  }

  String _buildSubtitle({required String postalCode, required String city}) {
    return '$postalCode $city'.trim();
  }

  String? _cleanSecondaryText(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final parts = text.split(',').map((part) => part.trim()).toList();
    if (parts.length <= 1) return text.trim();

    return parts.sublist(0, parts.length - 1).join(', ');
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

extension AddressSuggestionDetails on AddressSuggestion {
  bool get hasFullDetails =>
      street.isNotEmpty &&
      houseNumber.isNotEmpty &&
      postalCode.isNotEmpty &&
      city.isNotEmpty;
}
