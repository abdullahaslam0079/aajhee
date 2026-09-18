import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Defines the full Material 3 typescale for the application.
///
/// Prefer accessing styles through [BuildContext] extensions:
/// ```dart
/// Text('Hello', style: context.textTheme.titleLarge);
/// ```
TextTheme buildTextTheme() {
  const baseTextTheme = TextTheme(
    // ── Display ──────────────────────────────────────────────────────────────
    // Use for the largest, most impactful text on a screen.
    // Typically reserved for hero/marketing sections, splash screens,
    // or short one-word statements. Never use for body copy.

    /// 57 sp — Largest display text.
    /// Use for: splash screen titles, giant counters, hero numbers.
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
    ),

    /// 45 sp — Mid-size display text.
    /// Use for: prominent feature headlines, onboarding first-screen titles.
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.12,
    ),

    /// 36 sp — Smallest display text.
    /// Use for: section-level hero text, large marketing callouts.
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.15,
    ),

    // ── Headline ─────────────────────────────────────────────────────────────
    // Use for page/screen-level headings. Slightly smaller than Display —
    // works well as the primary title of a full page or major section.

    /// 32 sp — Large page-level heading.
    /// Use for: main screen titles (e.g. "My Profile"), large dialog headers.
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.2,
    ),

    /// 28 sp — Standard page-level heading.
    /// Use for: AppBar titles on content-heavy screens, sheet headers.
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.2,
    ),

    /// 24 sp — Compact page-level heading.
    /// Use for: section headings within a scrollable page, card group titles.
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      height: 1.22,
    ),

    // ── Title ─────────────────────────────────────────────────────────────────
    // Use for component-level titles and prominent labels inside cards,
    // lists, or dialogs. More emphasis than body, less than headline.

    /// 22 sp — Prominent component title.
    /// Use for: AppBar titles (standard), large list-section headers,
    ///          dialog/modal titles.
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.25,
    ),

    /// 16 sp — Standard component title.
    /// Use for: ListTile titles, card headings, tab labels, dropdown labels.
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
      height: 1.3,
    ),

    /// 14 sp — Compact component title.
    /// Use for: dense list item titles, chip labels, form field labels,
    ///          subtitle of a section.
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.3,
    ),

    // ── Body ──────────────────────────────────────────────────────────────────
    // Use for reading/content text. Optimised for legibility at comfortable
    // reading sizes. Default for paragraphs and descriptions.

    /// 16 sp — Primary body text.
    /// Use for: main paragraph text, message bubbles, article content,
    ///          default Text() inside cards.
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.01,
    ),

    /// 14 sp — Standard body text (most common).
    /// Use for: secondary descriptions, ListTile subtitles, form helper text,
    ///          dialog body copy. This is the workhorse style.
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.01,
    ),

    /// 12 sp — Small body / caption text.
    /// Use for: captions under images, timestamps, metadata, fine print,
    ///          secondary info below a ListTile.
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),

    // ── Label ─────────────────────────────────────────────────────────────────
    // Use for UI control labels, buttons, and navigation items.
    // NOT for body copy — these are designed to label interactive elements.

    /// 14 sp — Button and prominent control label.
    /// Use for: ElevatedButton / TextButton / OutlinedButton text,
    ///          navigation bar labels (selected), tab bar labels.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),

    /// 12 sp — Standard control label.
    /// Use for: chip text, badge text, tooltip text, navigation rail labels,
    ///          input counter text, overline headings.
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),

    /// 11 sp — Smallest control label.
    /// Use for: dense navigation labels, very small badges, annotation text,
    ///          data table column headers. Avoid for reading-heavy content.
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    ),
  );

  return baseTextTheme.apply(fontFamily: AppFonts.primary);
}
