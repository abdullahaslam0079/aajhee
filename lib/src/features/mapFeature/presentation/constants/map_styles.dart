/// Google Maps JSON styles for light/dark app themes.
abstract final class MapStyles {
  MapStyles._();

  /// Soft night style — readable roads, muted land, calm water.
  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1d21"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#b8b8c0"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d21"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#3a3a42"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#24242a"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8e8e98"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f2a24"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b8f7a"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2e2e34"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1a1a1e"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9a9aa3"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3a3a42"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1a1a1e"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#26262b"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f1a24"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5a6e82"}]}
]
''';
}
