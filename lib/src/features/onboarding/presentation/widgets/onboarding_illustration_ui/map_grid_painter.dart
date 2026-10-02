part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const divisions = 4;
    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
