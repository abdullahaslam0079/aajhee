import 'package:flutter/material.dart';

/// Predefined box shadows aligned with Material 3 elevation tiers.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppShadows.card,
///   ),
/// )
/// ```
abstract final class AppShadows {
  AppShadows._();

  /// No shadow — flat, tonal surface (elevation 0).
  static const List<BoxShadow> none = [];

  /// Minimal shadow — barely lifted surfaces (elevation 1).
  /// Use for: toggle surfaces, filled cards on white background.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A18181B),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Card shadow — clearly elevated content (elevation 2–3).
  /// Use for: cards, list items that are tappable, floating elements.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D18181B),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated shadow — significantly raised surface (elevation 6–8).
  /// Use for: FABs, dropdown menus, tooltips.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1418181B),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Modal shadow — overlay surfaces, dialogs, bottom sheets (elevation 12+).
  /// Use for: dialogs, modals, side sheets.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1F18181B),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
