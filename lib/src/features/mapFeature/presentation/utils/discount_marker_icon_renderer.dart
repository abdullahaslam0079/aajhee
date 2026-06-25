import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goluto/src/theme/app_fonts.dart';

abstract final class DiscountMarkerIconRenderer {
  static Future<BitmapDescriptor> render({
    required int discountPercent,
    required bool selected,
    required double devicePixelRatio,
    required Color primaryColor,
    required Color onPrimaryColor,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    TextStyle? labelStyle,
  }) async {
    final text = '$discountPercent% off';
    final scale = devicePixelRatio.clamp(1.0, 3.0);

    final textStyle = (labelStyle ?? const TextStyle(fontFamily: AppFonts.primary)).copyWith(
      fontFamily: AppFonts.primary,
      color: textColor,
      fontWeight: FontWeight.w700,
      fontSize: ((labelStyle?.fontSize ?? 14) * scale),
    );

    final iconStyle = TextStyle(
      fontFamily: 'MaterialIcons',
      fontSize: 14 * scale,
      color: onPrimaryColor,
    );

    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final iconSize = 22.0 * scale;
    final paddingH = 12.0 * scale;
    final paddingV = 8.0 * scale;
    final gap = 8.0 * scale;

    final pillWidth = paddingH + iconSize + gap + tp.width + paddingH;
    final pillHeight = (iconSize + paddingV * 2).clamp(
      34.0 * scale,
      46.0 * scale,
    );

    final pointerWidth = 18.0 * scale;
    final pointerHeight = 12.0 * scale;
    final tipDotRadius = 4.0 * scale;
    final tipDotGap = 2.0 * scale;
    final shadowPad = 12.0 * scale;
    final totalWidth = pillWidth + shadowPad * 2;
    final totalHeight = pillHeight +
        pointerHeight +
        tipDotGap +
        tipDotRadius * 2 +
        shadowPad * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final pillLeft = shadowPad;
    final pillTop = shadowPad;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillLeft, pillTop, pillWidth, pillHeight),
      Radius.circular(18.0 * scale),
    );

    final pointerTipX = pillLeft + pillWidth / 2;
    final pointerBaseY = pillTop + pillHeight;
    final pointerTipY = pointerBaseY + pointerHeight;
    final pointerHalfWidth = pointerWidth / 2;
    final pointerPath = Path()
      ..moveTo(pointerTipX - pointerHalfWidth, pointerBaseY - 2 * scale)
      ..quadraticBezierTo(
        pointerTipX - pointerHalfWidth * 0.35,
        pointerBaseY + pointerHeight * 0.55,
        pointerTipX,
        pointerTipY,
      )
      ..quadraticBezierTo(
        pointerTipX + pointerHalfWidth * 0.35,
        pointerBaseY + pointerHeight * 0.55,
        pointerTipX + pointerHalfWidth,
        pointerBaseY - 2 * scale,
      )
      ..close();

    final tipDotCenter = Offset(
      pointerTipX,
      pointerTipY + tipDotGap + tipDotRadius,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: selected ? 0.2 : 0.16)
      ..maskFilter = ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        9.0 * scale,
      );

    canvas.save();
    canvas.translate(0, 2.5 * scale);
    canvas.drawRRect(pillRect, shadowPaint);
    canvas.drawPath(pointerPath, shadowPaint);
    canvas.drawCircle(tipDotCenter, tipDotRadius + 1.5 * scale, shadowPaint);
    canvas.restore();

    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(pillRect, bgPaint);
    canvas.drawPath(pointerPath, bgPaint);

    final borderWidth = (selected ? 2.0 : 1.0) * scale;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = selected ? primaryColor : borderColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(pillRect, borderPaint);

    canvas.drawLine(
      Offset(pointerTipX - pointerHalfWidth, pointerBaseY - 2 * scale),
      Offset(pointerTipX, pointerTipY),
      borderPaint,
    );
    canvas.drawLine(
      Offset(pointerTipX + pointerHalfWidth, pointerBaseY - 2 * scale),
      Offset(pointerTipX, pointerTipY),
      borderPaint,
    );

    canvas.drawLine(
      Offset(pointerTipX - pointerHalfWidth + borderWidth, pointerBaseY),
      Offset(pointerTipX + pointerHalfWidth - borderWidth, pointerBaseY),
      Paint()
        ..color = backgroundColor
        ..strokeWidth = borderWidth + 1,
    );

    final tipFillPaint = Paint()
      ..color = selected ? primaryColor : textColor.withValues(alpha: 0.82);
    canvas.drawCircle(tipDotCenter, tipDotRadius, tipFillPaint);

    final tipRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = selected ? primaryColor : borderColor;
    canvas.drawCircle(tipDotCenter, tipDotRadius, tipRingPaint);

    final circleCenter = Offset(
      shadowPad + paddingH + iconSize / 2,
      shadowPad + pillHeight / 2,
    );
    final circlePaint = Paint()..color = primaryColor;
    canvas.drawCircle(circleCenter, iconSize / 2, circlePaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.local_offer.codePoint),
        style: iconStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - iconPainter.width / 2,
        circleCenter.dy - iconPainter.height / 2,
      ),
    );

    tp.paint(
      canvas,
      Offset(
        shadowPad + paddingH + iconSize + gap,
        shadowPad + (pillHeight - tp.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      totalWidth.ceil(),
      totalHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = Uint8List.view(byteData!.buffer);
    return BitmapDescriptor.fromBytes(bytes);
  }
}
