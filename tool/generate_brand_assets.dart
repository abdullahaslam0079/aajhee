import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders Goluto brand assets using bundled Inter 800 — matches splash wordmark.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fontData = await rootBundle.load('assets/fonts/Inter-800.ttf');
  final loader = FontLoader('Inter')..addFont(Future.value(fontData));
  await loader.load();

  const brandColor = Color(0xFF1F1F21);
  const white = Color(0xFFFFFFFF);

  await _renderWordmark(
    outputPath: 'assets/images/goluto_logo.png',
    text: 'Goluto',
    fontSize: 280,
    color: brandColor,
    backgroundColor: white,
    width: 2400,
    height: 800,
    transparentBackground: true,
  );

  await _renderWordmark(
    outputPath: 'assets/images/goluto_logo_white_bg.png',
    text: 'Goluto',
    fontSize: 280,
    color: brandColor,
    backgroundColor: white,
    width: 2400,
    height: 800,
    transparentBackground: false,
  );

  await _renderWordmark(
    outputPath: 'assets/images/goluto_logo_dark_bg.png',
    text: 'Goluto',
    fontSize: 280,
    color: white,
    backgroundColor: brandColor,
    width: 2400,
    height: 800,
    transparentBackground: false,
  );

  await _renderAppIcon(
    outputPath: 'assets/images/app_icon_source.png',
    size: 1024,
    text: 'Go',
    foreground: brandColor,
    background: white,
  );

  await _renderAppIconLetter(
    outputPath: 'assets/images/app_icon_foreground.png',
    size: 1024,
    text: 'Go',
    foreground: brandColor,
  );

  stdout.writeln('Brand assets generated successfully.');
}

Future<void> _renderWordmark({
  required String outputPath,
  required String text,
  required double fontSize,
  required Color color,
  required Color backgroundColor,
  required int width,
  required int height,
  required bool transparentBackground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (!transparentBackground) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = backgroundColor,
    );
  }

  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: fontSize * -0.009,
        height: 1,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      (width - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ),
  );

  await _savePng(recorder, width, height, outputPath);
}

Future<void> _renderAppIcon({
  required String outputPath,
  required int size,
  required String text,
  required Color foreground,
  required Color background,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  const radius = 224.0; // ~22% corner radius for iOS-style icon

  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, s, s),
    Radius.circular(radius * (s / 1024)),
  );
  canvas.drawRRect(rrect, Paint()..color = background);

  final fontSize = s * 0.38;
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: fontSize * -0.009,
        height: 1,
        color: foreground,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      (s - textPainter.width) / 2,
      (s - textPainter.height) / 2 - s * 0.02,
    ),
  );

  await _savePng(recorder, size, size, outputPath);
}

Future<void> _renderAppIconLetter({
  required String outputPath,
  required int size,
  required String text,
  required Color foreground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();

  final fontSize = s * 0.38;
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: fontSize * -0.009,
        height: 1,
        color: foreground,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      (s - textPainter.width) / 2,
      (s - textPainter.height) / 2 - s * 0.02,
    ),
  );

  await _savePng(recorder, size, size, outputPath);
}

Future<void> _savePng(
  ui.PictureRecorder recorder,
  int width,
  int height,
  String outputPath,
) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Failed to encode PNG for $outputPath');
  }
  await File(outputPath).writeAsBytes(byteData.buffer.asUint8List());
  stdout.writeln('Wrote $outputPath (${width}x$height)');
}
