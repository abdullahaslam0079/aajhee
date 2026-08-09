import 'package:flutter/material.dart';

/// Single border-radius system for the app.
///
/// Rules:
/// - Use [input] / [button] / [card] / [dialog] semantic aliases in UI code.
/// - Use [full] only for pills (filter chips, % off badges, small meta chips).
/// - Nested surfaces step down one level (card → md, md → sm).
/// - Prefer rounded squares ([iconButton]) over circles for icon buttons.
///
/// Scale: 6 → 8 → 12 → 16 → 20
abstract final class AppBorders {
  AppBorders._();

  // ── Scale ─────────────────────────────────────────────────────────────────

  /// 6 — logos, checkboxes, tiny thumbnails.
  static const BorderRadius xs = BorderRadius.all(Radius.circular(6));

  /// 8 — small nested surfaces, tooltips.
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));

  /// 12 — search, inputs, buttons, icon buttons, list tiles.
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));

  /// 16 — cards, panels, toasts.
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));

  /// 20 — dialogs, large feature surfaces.
  static const BorderRadius xl = BorderRadius.all(Radius.circular(20));

  /// Sheet top corners — matches [xl].
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  /// Pill / stadium — filter chips, discount badges, meta chips only.
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));

  // ── Semantic aliases ──────────────────────────────────────────────────────

  static const BorderRadius button = md;
  static const BorderRadius iconButton = md;
  static const BorderRadius card = lg;
  static const BorderRadius input = md;
  static const BorderRadius dialog = xl;

  // ── Shapes ────────────────────────────────────────────────────────────────

  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(
    borderRadius: sm,
  );

  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: md,
  );

  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(
    borderRadius: lg,
  );

  static const RoundedRectangleBorder shapeXl = RoundedRectangleBorder(
    borderRadius: xl,
  );

  static const RoundedRectangleBorder shapeIconButton = RoundedRectangleBorder(
    borderRadius: iconButton,
  );

  static const StadiumBorder stadium = StadiumBorder();
}
