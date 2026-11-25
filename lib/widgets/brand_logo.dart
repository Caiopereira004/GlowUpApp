import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlowUpLogoPainter(),
      ),
    );
  }
}

class _GlowUpLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.31));

    // Fundo degradê Rosé Profundo
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A3248), Color(0xFF9E4761), Color(0xFFD4849A)],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // Borda sutil luminosa
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.024
      ..color = Colors.white.withValues(alpha: 0.24);
    canvas.drawRRect(rrect.deflate(size.width * 0.012), borderPaint);

    // Arco orbital champagne
    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.47, size.height * 0.51),
      radius: size.width * 0.27,
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.038
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFF7E4EA), Color(0xFFE7C299)],
      ).createShader(arcRect);
    canvas.drawArc(arcRect, 0.25, 4.1, false, arcPaint);

    // Gota central luminosa
    final dropPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.26)
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.26,
        size.width * 0.37,
        size.height * 0.43,
        size.width * 0.37,
        size.height * 0.54,
      )
      ..arcToPoint(
        Offset(size.width * 0.68, size.height * 0.54),
        radius: Radius.circular(size.width * 0.155),
        clockwise: false,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.43,
        size.width * 0.52,
        size.height * 0.26,
        size.width * 0.52,
        size.height * 0.26,
      )
      ..close();

    canvas.drawPath(
      dropPath,
      Paint()..color = Colors.white.withValues(alpha: 0.94),
    );

    // Estrela champagne superior direita
    final starPath = Path()
      ..moveTo(size.width * 0.71, size.height * 0.23)
      ..lineTo(size.width * 0.73, size.height * 0.29)
      ..lineTo(size.width * 0.79, size.height * 0.31)
      ..lineTo(size.width * 0.73, size.height * 0.33)
      ..lineTo(size.width * 0.71, size.height * 0.39)
      ..lineTo(size.width * 0.69, size.height * 0.33)
      ..lineTo(size.width * 0.63, size.height * 0.31)
      ..lineTo(size.width * 0.69, size.height * 0.29)
      ..close();

    canvas.drawPath(starPath, Paint()..color = const Color(0xFFF5D7B2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
