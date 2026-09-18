/// Google Maps JSON styles for light/dark app themes.
abstract final class MapStyles {
  MapStyles._();

  /// Neutral night style — charcoal land, no blue cast.
  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1c1c1c"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#a3a3a3"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#121212"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#2e2e2e"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#242424"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e2420"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b8f7a"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#121212"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2e2e2e"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#121212"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#242424"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e0e0e"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5c5c5c"}]}
]
''';
}
