// Conditional import for dart:io
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:flutter/foundation.dart' show kIsWeb, WriteBuffer;
import 'package:flutter/material.dart' hide Size;
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;
import '../models/face_embedding_model.dart';
import '../utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Conditional import for File and Directory
import 'dart:io' if (dart.library.html) '../utils/io_stub.dart' as io;

class FaceRecognitionService {
  final FaceDetector _faceDetector;

  FaceRecognitionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: true,
            enableLandmarks: true,
            enableClassification: true,
            enableTracking: true,
            minFaceSize: 0.1,
          ),
        );

  // Detect faces in camera image
  Future<List<Face>> detectFaces(CameraImage cameraImage) async {
    final inputImage = _inputImageFromCameraImage(cameraImage);
    if (inputImage == null) return [];

    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      print('Error detecting faces: $e');
      return [];
    }
  }

  // Detect faces from file path
  Future<List<Face>> detectFacesFromFile(String imagePath) async {
    if (kIsWeb) {
      // On web, we need to use InputImage.fromBytes instead
      // This method should be called with image bytes, not file path
      throw UnsupportedError('detectFacesFromFile not supported on web. Use detectFacesFromBytes instead.');
    }
    
    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      print('Error detecting faces from file: $e');
      return [];
    }
  }

  // Detect faces from image bytes (for web support)
  Future<List<Face>> detectFacesFromBytes(Uint8List imageBytes, InputImageMetadata metadata) async {
    final inputImage = InputImage.fromBytes(bytes: imageBytes, metadata: metadata);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      print('Error detecting faces from bytes: $e');
      return [];
    }
  }

  // Extract face embedding from detected face
  // Note: This is a simplified version. For production, you'd use a proper face recognition model
  Future<List<double>> extractFaceEmbedding(Face face, img.Image image) async {
    // This is a placeholder implementation
    // In a real app, you'd use a face recognition model (like MobileFaceNet, ArcFace, etc.)
    // to generate embeddings from the face region

    final rect = face.boundingBox;
    final faceRegion = img.copyCrop(
      image,
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );

    // Resize to standard size (e.g., 112x112 for face recognition)
    final resizedFace = img.copyResize(faceRegion, width: 112, height: 112);

    // Convert to normalized embedding vector
    // This is a simplified approach - in production, use a trained model
    final embedding = <double>[];
      final pixels = resizedFace.getBytes();
    
    for (int i = 0; i < pixels.length; i += 3) {
      // Simple feature extraction (normalize RGB values)
      final r = pixels[i] / 255.0;
      final g = pixels[i + 1] / 255.0;
      final b = pixels[i + 2] / 255.0;
      embedding.add(r);
      embedding.add(g);
      embedding.add(b);
    }

    // Normalize the embedding vector
    return _normalizeVector(embedding);
  }

  // Normalize a vector to unit length
  List<double> _normalizeVector(List<double> vector) {
    double sum = 0.0;
    for (final value in vector) {
      sum += value * value;
    }
    final magnitude = sum > 0 ? sqrt(sum) : 1.0;
    return vector.map((v) => v / magnitude).toList();
  }

  double sqrt(double value) {
    if (value == 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }

  // Match face with stored embeddings
  Future<FaceMatchResult?> matchFace(
    List<double> embedding,
    List<FaceEmbedding> storedEmbeddings,
  ) async {
    double bestSimilarity = 0.0;
    FaceEmbedding? bestMatch;

    for (final storedEmbedding in storedEmbeddings) {
      final similarity = _cosineSimilarity(embedding, storedEmbedding.embedding);
      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestMatch = storedEmbedding;
      }
    }

    if (bestSimilarity >= AppConstants.faceRecognitionThreshold && bestMatch != null) {
      return FaceMatchResult(
        userId: bestMatch.userId,
        similarity: bestSimilarity,
        embedding: bestMatch,
      );
    }

    return null;
  }

  // Calculate cosine similarity between two vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // Save face image to storage
  Future<String> saveFaceImage(img.Image faceImage, String userId) async {
    if (kIsWeb) {
      // On web, we can't save to file system directly
      // Return a placeholder path or use browser storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'web_${userId}_$timestamp.jpg';
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final faceImagesDir = io.Directory(path.join(directory.path, AppConstants.faceImagesFolder));
    
    if (!await faceImagesDir.exists()) {
      await faceImagesDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${userId}_$timestamp.jpg';
    final filePath = path.join(faceImagesDir.path, fileName);

    final file = io.File(filePath);
    await file.writeAsBytes(img.encodeJpg(faceImage));

    return filePath;
  }

  // Convert CameraImage to InputImage
  InputImage? _inputImageFromCameraImage(CameraImage cameraImage) {
    try {
      // Determine image format based on camera image format
      InputImageFormat format;
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        format = InputImageFormat.yuv420;
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        format = InputImageFormat.bgra8888;
      } else if (cameraImage.format.group == ImageFormatGroup.nv21) {
        format = InputImageFormat.nv21;
      } else {
        // Default to yuv420 for iOS
        format = InputImageFormat.yuv420;
      }

      // Determine rotation - iOS front camera typically needs 270deg rotation
      // For YUV420 on iOS front camera, use 270deg rotation
      InputImageRotation rotation = InputImageRotation.rotation0deg;
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        // iOS front camera with YUV420 typically needs 270deg rotation
        rotation = InputImageRotation.rotation270deg;
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        // For BGRA format, might need different rotation
        rotation = InputImageRotation.rotation90deg;
      }

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // For YUV420, we need to handle multiple planes properly
      // Use bytesPerRow from first plane, or default to width if not available
      final bytesPerRow = cameraImage.planes.isNotEmpty 
          ? cameraImage.planes[0].bytesPerRow 
          : cameraImage.width;

      final inputImageData = InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

// Face match result
class FaceMatchResult {
  final String userId;
  final double similarity;
  final FaceEmbedding embedding;

  FaceMatchResult({
    required this.userId,
    required this.similarity,
    required this.embedding,
  });
}

