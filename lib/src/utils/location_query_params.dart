class LocationQueryParams {
  LocationQueryParams._();

  static Map<String, dynamic>? fromAddressId(String? addressId) {
    final trimmed = addressId?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return {'address_id': trimmed};
  }
}
