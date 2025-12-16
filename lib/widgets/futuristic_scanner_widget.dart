import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FuturisticScannerWidget extends StatelessWidget {
  final List<Face> detectedFaces;
  final CameraController cameraController;
  final bool isFaceDetected;
  final bool isFaceLocked;
  final Animation<double> pulseAnimation;
  final Animation<double> scanAnimation;
  final Animation<double> lockAnimation;

  const FuturisticScannerWidget({
    super.key,
    required this.detectedFaces,
    required this.cameraController,
    required this.isFaceDetected,
    required this.isFaceLocked,
    required this.pulseAnimation,
    required this.scanAnimation,
    required this.lockAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = math.min(size.width * 0.75, size.height * 0.5);
    
    return AnimatedBuilder(
      animation: Listenable.merge([pulseAnimation, scanAnimation, lockAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(scannerSize, scannerSize),
          painter: FuturisticScannerPainter(
            detectedFaces: detectedFaces,
            cameraController: cameraController,
            isFaceDetected: isFaceDetected,
            isFaceLocked: isFaceLocked,
            pulseValue: pulseAnimation.value,
            scanValue: scanAnimation.value,
            lockValue: lockAnimation.value,
          ),
        );
      },
    );
  }
}

class FuturisticScannerPainter extends CustomPainter {
  final List<Face> detectedFaces;
  final CameraController cameraController;
  final bool isFaceDetected;
  final bool isFaceLocked;
  final double pulseValue;
  final double scanValue;
  final double lockValue;

  FuturisticScannerPainter({
    required this.detectedFaces,
    required this.cameraController,
    required this.isFaceDetected,
    required this.isFaceLocked,
    required this.pulseValue,
    required this.scanValue,
    required this.lockValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw face bounding box if detected
    if (detectedFaces.isNotEmpty && cameraController.value.isInitialized) {
      _drawFaceOverlay(canvas, size);
    }

    // Main circular scanner frame
    _drawScannerFrame(canvas, center, radius);

    // Scanning line
    _drawScanningLine(canvas, center, radius);

    // Corner decorations
    _drawCornerDecorations(canvas, center, radius);

    // Lock animation overlay
    if (isFaceLocked) {
      _drawLockOverlay(canvas, center, radius);
    }

    // Pulse effect
    if (isFaceDetected || isFaceLocked) {
      _drawPulseEffect(canvas, center, radius);
    }
  }

  void _drawScannerFrame(Canvas canvas, Offset center, double radius) {
    final adjustedRadius = radius * (0.95 + (pulseValue * 0.05));
    
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88).withOpacity(0.3)
          : isFaceDetected
              ? const Color(0xFF00D4FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, adjustedRadius + 10, outerGlowPaint);

    // Main frame with gradient
    final framePaint = Paint()
      ..shader = LinearGradient(
        colors: isFaceLocked
            ? [
                const Color(0xFF00FF88),
                const Color(0xFF00D4FF),
              ]
            : isFaceDetected
                ? [
                    const Color(0xFF00D4FF),
                    const Color(0xFF9D4EDD),
                  ]
                : [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.3),
                  ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: adjustedRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, adjustedRadius, framePaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88).withOpacity(0.4)
          : isFaceDetected
              ? const Color(0xFF00D4FF).withOpacity(0.3)
              : Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, adjustedRadius - 2, innerGlowPaint);
  }

  void _drawScanningLine(Canvas canvas, Offset center, double radius) {
    if (!isFaceDetected && !isFaceLocked) return;

    final angle = scanValue * 2 * math.pi;
    final startRadius = radius * 0.7;
    final endRadius = radius * 0.95;

    final startX = center.dx + math.cos(angle) * startRadius;
    final startY = center.dy + math.sin(angle) * startRadius;
    final endX = center.dx + math.cos(angle) * endRadius;
    final endY = center.dy + math.sin(angle) * endRadius;

    final scanPaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88)
          : const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      scanPaint,
    );

    // Glowing dot at the end
    final dotPaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88)
          : const Color(0xFF00D4FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
  }

  void _drawCornerDecorations(Canvas canvas, Offset center, double radius) {
    final cornerLength = 20.0;
    final cornerWidth = 3.0;
    final adjustedRadius = radius * (0.95 + (pulseValue * 0.05));

    final cornerPaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88)
          : isFaceDetected
              ? const Color(0xFF00D4FF)
              : Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    // Top Left
    _drawCorner(canvas, center, adjustedRadius, -math.pi * 0.75, cornerPaint, cornerLength);
    // Top Right
    _drawCorner(canvas, center, adjustedRadius, -math.pi * 0.25, cornerPaint, cornerLength);
    // Bottom Left
    _drawCorner(canvas, center, adjustedRadius, math.pi * 0.75, cornerPaint, cornerLength);
    // Bottom Right
    _drawCorner(canvas, center, adjustedRadius, math.pi * 0.25, cornerPaint, cornerLength);
  }

  void _drawCorner(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint paint,
    double length,
  ) {
    final cornerX = center.dx + math.cos(angle) * radius;
    final cornerY = center.dy + math.sin(angle) * radius;

    // Outer line
    final outerX = cornerX + math.cos(angle + math.pi * 0.5) * length;
    final outerY = cornerY + math.sin(angle + math.pi * 0.5) * length;

    canvas.drawLine(Offset(cornerX, cornerY), Offset(outerX, outerY), paint);

    // Inner line
    final innerX = cornerX + math.cos(angle - math.pi * 0.5) * length;
    final innerY = cornerY + math.sin(angle - math.pi * 0.5) * length;

    canvas.drawLine(Offset(cornerX, cornerY), Offset(innerX, innerY), paint);
  }

  void _drawLockOverlay(Canvas canvas, Offset center, double radius) {
    final lockRadius = radius * (0.8 + (lockValue * 0.15));

    // Lock circles
    final lockPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FF88).withOpacity(0.4 * lockValue),
          const Color(0xFF00FF88).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: lockRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, lockRadius, lockPaint);

    // Lock icon
    final iconPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final iconSize = 30.0 * lockValue;
    final lockTop = center.dy - iconSize * 0.5;

    // Draw lock body
    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, lockTop + iconSize * 0.4),
        width: iconSize * 0.6,
        height: iconSize * 0.6,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(lockRect, iconPaint);

    // Draw lock shackle
    final shacklePath = Path()
      ..moveTo(center.dx - iconSize * 0.25, lockTop + iconSize * 0.4)
      ..arcToPoint(
        Offset(center.dx + iconSize * 0.25, lockTop + iconSize * 0.4),
        radius: Radius.circular(iconSize * 0.25),
        clockwise: false,
      );

    canvas.drawPath(shacklePath, iconPaint);
  }

  void _drawPulseEffect(Canvas canvas, Offset center, double radius) {
    final pulseRadius = radius * (1.0 + pulseValue * 0.2);

    final pulsePaint = Paint()
      ..color = isFaceLocked
          ? const Color(0xFF00FF88).withOpacity(0.3 * (1 - pulseValue))
          : const Color(0xFF00D4FF).withOpacity(0.2 * (1 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  void _drawFaceOverlay(Canvas canvas, Size size) {
    if (detectedFaces.isEmpty) return;

    try {
      final face = detectedFaces.first;
      final imageSize = cameraController.value.previewSize;
      if (imageSize == null) return;

      // Calculate scale to fit camera preview to screen
      final scaleX = size.width / imageSize.height;
      final scaleY = size.height / imageSize.width;

      // Camera preview is rotated, so swap dimensions
      final faceRect = face.boundingBox;
      
      // Transform face coordinates to screen coordinates
      final screenRect = Rect.fromLTWH(
        (faceRect.top) * scaleX,
        (faceRect.left) * scaleY,
        faceRect.height * scaleX,
        faceRect.width * scaleY,
      );

      // Only draw if face is roughly in the center (within scanner area)
      final center = Offset(size.width / 2, size.height / 2);
      final scannerRadius = size.width / 2 * 0.95;
      final faceCenter = Offset(
        screenRect.center.dx,
        screenRect.center.dy,
      );

      final distance = (center - faceCenter).distance;
      if (distance > scannerRadius * 0.8) return;

      // Draw face bounding box with glow
      final facePaint = Paint()
        ..color = isFaceLocked
            ? const Color(0xFF00FF88)
            : const Color(0xFF00D4FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final roundedRect = RRect.fromRectAndRadius(
        screenRect,
        const Radius.circular(8),
      );

      canvas.drawRRect(roundedRect, facePaint);
    } catch (e) {
      // Handle coordinate transformation errors silently
    }
  }

  @override
  bool shouldRepaint(FuturisticScannerPainter oldDelegate) {
    return oldDelegate.isFaceDetected != isFaceDetected ||
        oldDelegate.isFaceLocked != isFaceLocked ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.scanValue != scanValue ||
        oldDelegate.lockValue != lockValue ||
        oldDelegate.detectedFaces.length != detectedFaces.length;
  }
}

