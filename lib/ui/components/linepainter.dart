import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final double textWidth;
  final bool hasGap;

  LinePainter({required this.textWidth, this.hasGap = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(size.width, size.height / 2);

    if (hasGap) {
      final gapStart = (size.width - textWidth) / 2;
      final gapEnd = gapStart + textWidth;

      canvas.drawLine(startPoint, Offset(gapStart, size.height / 2), paint);
      canvas.drawLine(Offset(gapEnd, size.height / 2), endPoint, paint);
    } else {
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}