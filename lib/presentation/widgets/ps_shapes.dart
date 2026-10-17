import 'package:flutter/material.dart';

enum PsShape { triangle, circle, cross, square }

/// Classic PlayStation button colors.
const Color kPsShapeGreen = Color(0xFF3ABB6F);
const Color kPsShapeRed = Color(0xFFEA3E5C);
const Color kPsShapeBlue = Color(0xFF4C8FD8);
const Color kPsShapePink = Color(0xFFD562BE);

Color psShapeColor(PsShape shape) {
  switch (shape) {
    case PsShape.triangle:
      return kPsShapeGreen;
    case PsShape.circle:
      return kPsShapeRed;
    case PsShape.cross:
      return kPsShapeBlue;
    case PsShape.square:
      return kPsShapePink;
  }
}

class PsShapeIcon extends StatelessWidget {
  const PsShapeIcon(
    this.shape, {
    super.key,
    this.size = 14,
    this.opacity = 1.0,
  });

  final PsShape shape;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _PsShapePainter(shape, color: psShapeColor(shape)),
      isComplex: false,
      willChange: false,
    );
    return opacity == 1.0 ? icon : Opacity(opacity: opacity, child: icon);
  }
}

/// The four PlayStation shapes in a row, in their classic colors.
class PsShapeStrip extends StatelessWidget {
  const PsShapeStrip({super.key, this.size = 12, this.spacing = 6});

  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final shape in PsShape.values)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: PsShapeIcon(shape, size: size),
          ),
      ],
    );
  }
}

class _PsShapePainter extends CustomPainter {
  _PsShapePainter(this.shape, {required this.color});

  final PsShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (shape) {
      case PsShape.triangle:
        final path = Path()
          ..moveTo(size.width / 2, size.height * 0.08)
          ..lineTo(size.width * 0.92, size.height * 0.88)
          ..lineTo(size.width * 0.08, size.height * 0.88)
          ..close();
        canvas.drawPath(path, stroke);
      case PsShape.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width * 0.38,
          stroke,
        );
      case PsShape.cross:
        final pad = size.width * 0.14;
        final len = size.width - pad * 2;
        canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad + len), stroke);
        canvas.drawLine(Offset(pad + len, pad), Offset(pad, pad + len), stroke);
      case PsShape.square:
        final pad = size.width * 0.16;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                pad, pad, size.width - pad * 2, size.height - pad * 2),
            Radius.circular(size.width * 0.12),
          ),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _PsShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}
