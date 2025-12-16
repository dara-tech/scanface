import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceScannerWidget extends StatelessWidget {
  final CameraController controller;
  final List<Face> faces;
  final Function()? onCapture;

  const FaceScannerWidget({
    super.key,
    required this.controller,
    required this.faces,
    this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(controller),
        CustomPaint(
          painter: FaceOverlayPainter(faces),
          child: Container(),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.large(
              onPressed: onCapture,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
      ],
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;

  FaceOverlayPainter(this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (final face in faces) {
      canvas.drawRect(face.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}

