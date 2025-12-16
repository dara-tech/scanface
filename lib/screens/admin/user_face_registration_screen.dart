import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../services/face_recognition_service.dart';
import '../../services/database_service.dart';
import '../../models/face_embedding_model.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
// Conditional import for File
import 'dart:io' if (dart.library.html) '../../utils/io_stub.dart' as io;

class UserFaceRegistrationScreen extends StatefulWidget {
  final User user;

  const UserFaceRegistrationScreen({super.key, required this.user});

  @override
  State<UserFaceRegistrationScreen> createState() => _UserFaceRegistrationScreenState();
}

class _UserFaceRegistrationScreenState extends State<UserFaceRegistrationScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isProcessing = false;
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final DatabaseService _dbService = DatabaseService.instance;
  final _uuid = const Uuid();
  int _capturedCount = 0;
  final int _requiredCaptures = 3;
  List<Face> _detectedFaces = [];
  bool _isFaceDetected = false;
  DateTime? _lastAutoCaptureTime;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
          _showError('${AppLocalizations.of(context)!.error}: No camera available.\n\n⚠️ iOS Simulator does NOT support camera.\n\nOptions:\n1. Use a REAL iPhone/iPad device\n2. Test on macOS (camera works there)\n3. For simulator testing, camera features will not work');
        }
        return;
      }

      // Prefer front camera for face registration
      CameraDescription? selectedCamera;
      try {
        selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        // If front camera not found, use first available camera
        selectedCamera = _cameras![0];
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: kIsWeb 
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420, // Use YUV420 for better iOS compatibility with ML Kit
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        _startFaceDetection();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        String errorMessage;
        if (e.toString().contains('permission') || e.toString().contains('Permission')) {
          errorMessage = '${AppLocalizations.of(context)!.error}: Camera permission denied.\n\n⚠️ iOS Simulator does NOT support camera.\n\nTo test camera:\n1. Use a REAL iPhone/iPad device\n2. Or test on macOS\n\nOn real device:\nSettings > Privacy & Security > Camera > Enable for this app';
        } else if (e.toString().contains('No cameras available') || e.toString().contains('Camera not available')) {
          errorMessage = '${AppLocalizations.of(context)!.error}: Camera not available.\n\n⚠️ iOS Simulator does NOT support camera.\n\nTo test camera:\n1. Use a REAL iPhone/iPad device\n2. Or test on macOS\n\nOn real device:\nMake sure camera is not being used by another app';
        } else {
          errorMessage = '${AppLocalizations.of(context)!.error}: Failed to initialize camera.\n\n$e\n\n⚠️ iOS Simulator does NOT support camera.\n\nTo test camera:\n1. Use a REAL iPhone/iPad device\n2. Or test on macOS';
        }
        _showError(errorMessage);
      }
    }
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // Use camera stream for better performance and iOS compatibility
    _cameraController!.startImageStream((CameraImage cameraImage) async {
      if (_isProcessingFrame || !mounted || _isProcessing) return;
      
      _isProcessingFrame = true;
      try {
        // Use direct camera image processing (works better on iOS)
        final faces = await _faceService.detectFaces(cameraImage);

        if (mounted) {
          setState(() {
            _detectedFaces = faces;
            _isFaceDetected = faces.isNotEmpty && faces.length == 1;
            
            // Auto-capture when face is detected (with delay to ensure quality)
            if (_isFaceDetected && _capturedCount < _requiredCaptures) {
              final now = DateTime.now();
              // Wait at least 1 second between captures and ensure face is stable
              if (_lastAutoCaptureTime == null || 
                  now.difference(_lastAutoCaptureTime!).inSeconds >= 2) {
                _lastAutoCaptureTime = now;
                // Small delay to ensure face is stable before capturing
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted && _isFaceDetected && !_isProcessing) {
                    _captureAndSaveFace();
                  }
                });
              }
            }
          });
        }
      } catch (e) {
        // Silently handle errors during continuous detection
        print('Error in face detection: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> _captureAndSaveFace() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      Uint8List imageBytes;
      
      if (kIsWeb) {
        imageBytes = Uint8List.fromList(await image.readAsBytes());
      } else {
        final imageFile = io.File(image.path);
        imageBytes = Uint8List.fromList(await imageFile.readAsBytes());
      }
      
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Detect faces
      List<Face> faces;
      if (kIsWeb) {
        // On web, face detection from file path is not supported
        // This needs proper web camera handling
        throw UnsupportedError('Face detection from file not supported on web. Please use image picker.');
      } else {
        faces = await _faceService.detectFacesFromFile(image.path);
      }
      if (faces.isEmpty) {
        throw Exception('No face detected. Please ensure face is clearly visible.');
      }

      if (faces.length > 1) {
        throw Exception('Multiple faces detected. Please ensure only one person is in frame.');
      }

      final face = faces.first;

      // Extract face embedding
      final embedding = await _faceService.extractFaceEmbedding(face, decodedImage);

      // Save face image
      final faceImagePath = await _faceService.saveFaceImage(decodedImage, widget.user.id);

      // Save face embedding
      final faceEmbedding = FaceEmbedding(
        id: _uuid.v4(),
        userId: widget.user.id,
        embedding: embedding,
        imagePath: faceImagePath,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _dbService.insertFaceEmbedding(faceEmbedding);

      setState(() {
        _capturedCount++;
        _isProcessing = false;
        _lastAutoCaptureTime = null; // Reset timer for next capture
      });

      if (_capturedCount >= _requiredCaptures) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.success),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showSuccess('Face captured ${_capturedCount}/$_requiredCaptures');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _cameraController == null || !_cameraController!.value.isInitialized
              ? Center(child: Text(AppLocalizations.of(context)!.error))
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          CameraPreview(_cameraController!),
                          // Face detection overlay
                          if (_detectedFaces.isNotEmpty)
                            CustomPaint(
                              painter: FaceOverlayPainter(_detectedFaces, _cameraController!),
                              child: Container(),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isFaceDetected ? Colors.green : Colors.white,
                                width: _isFaceDetected ? 3 : 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.all(40),
                          ),
                          Positioned(
                            top: 60,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.black54,
                              child: Column(
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.processing} ${_capturedCount + 1}/$_requiredCaptures',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _capturedCount / _requiredCaptures,
                                    backgroundColor: Colors.grey,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isFaceDetected 
                                        ? 'Face detected! Capturing...' 
                                        : AppLocalizations.of(context)!.positionYourFace,
                                    style: TextStyle(
                                      color: _isFaceDetected ? Colors.green : Colors.white,
                                      fontSize: 14,
                                      fontWeight: _isFaceDetected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (_capturedCount < _requiredCaptures)
                            ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _captureAndSaveFace,
                              icon: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt),
                              label: Text(_isProcessing ? AppLocalizations.of(context)!.processing : AppLocalizations.of(context)!.faceRegistration),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            )
                          else
                            Text(
                              AppLocalizations.of(context)!.success,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Face overlay painter to draw detected faces
class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final CameraController cameraController;

  FaceOverlayPainter(this.faces, this.cameraController);

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty || !cameraController.value.isInitialized) return;

    try {
      final face = faces.first;
      final imageSize = cameraController.value.previewSize;
      if (imageSize == null) return;

      // Calculate scale to fit camera preview to screen
      // Camera preview is rotated, so we need to account for that
      final scaleX = size.width / imageSize.height;
      final scaleY = size.height / imageSize.width;

      // Transform face coordinates to screen coordinates
      final faceRect = face.boundingBox;
      final screenRect = Rect.fromLTWH(
        (faceRect.top) * scaleX,
        (faceRect.left) * scaleY,
        faceRect.height * scaleX,
        faceRect.width * scaleY,
      );

      // Draw face bounding box with glow
      final facePaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final roundedRect = RRect.fromRectAndRadius(
        screenRect,
        const Radius.circular(8),
      );

      canvas.drawRRect(roundedRect, facePaint);
    } catch (e) {
      // Handle coordinate transformation errors silently
      print('Error drawing face overlay: $e');
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces.length != faces.length;
  }
}

