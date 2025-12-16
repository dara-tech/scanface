import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../services/face_recognition_service.dart';
import '../../services/database_service.dart';
import '../../widgets/futuristic_scanner_widget.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
// Conditional import for File
import 'dart:io' if (dart.library.html) '../../utils/io_stub.dart' as io;

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isProcessing = false;
  bool _isFaceDetected = false;
  bool _isFaceLocked = false;
  String? _currentUserName;
  DateTime? _checkInTime;
  
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  Timer? _faceDetectionTimer;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _lockController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _lockAnimation;

  List<Face> _detectedFaces = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
    _loadCurrentUser();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _lockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadCurrentUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (mounted) {
      setState(() {
        _currentUserName = user?.name ?? 'User';
      });
    }
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

      // Prefer front camera for face recognition
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
        ResolutionPreset.high,
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
    bool isProcessingFrame = false;
    
    _cameraController!.startImageStream((CameraImage cameraImage) async {
      if (isProcessingFrame || !mounted) return;
      
      isProcessingFrame = true;
      try {
        // Use direct camera image processing (works better on iOS)
        final faces = await _faceService.detectFaces(cameraImage);

        if (mounted) {
          setState(() {
            _detectedFaces = faces;
            _isFaceDetected = faces.isNotEmpty && faces.length == 1;
            
            if (_isFaceDetected && !_isFaceLocked) {
              _checkFaceRecognition();
            } else if (!_isFaceDetected && _isFaceLocked) {
              _isFaceLocked = false;
              _lockController.reverse();
            }
          });
        }
      } catch (e) {
        // Silently handle errors during continuous detection
        print('Error in face detection: $e');
      } finally {
        isProcessingFrame = false;
      }
    });
  }

  Future<void> _checkFaceRecognition() async {
    if (_isProcessing || _isFaceLocked) return;
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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
        return;
      }

      // Detect faces
      List<Face> faces;
      if (kIsWeb) {
        // On web, we need to use bytes-based detection
        // This is a simplified version - proper implementation would use InputImage.fromBytes
        faces = [];
      } else {
        faces = await _faceService.detectFacesFromFile(image.path);
      }
      
      if (faces.isEmpty || faces.length > 1) {
        if (!kIsWeb) {
          final imageFile = io.File(image.path);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
        return;
      }

      final face = faces.first;
      final embedding = await _faceService.extractFaceEmbedding(face, decodedImage);
      final storedEmbeddings = await _dbService.getAllFaceEmbeddings();

      if (storedEmbeddings.isEmpty) {
        if (!kIsWeb) {
          final imageFile = io.File(image.path);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
        return;
      }

      final matchResult = await _faceService.matchFace(embedding, storedEmbeddings);

      if (matchResult != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        if (userId != null && matchResult.userId == userId) {
          if (mounted) {
            setState(() {
              _isFaceLocked = true;
              _checkInTime = DateTime.now();
            });
            _lockController.forward();
            
            // Auto check-in after lock
            Future.delayed(const Duration(milliseconds: 1500), () {
              _processCheckIn();
            });
          }
        }
      }

      // Clean up
      if (!kIsWeb) {
        final imageFile = io.File(image.path);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } else {
        // On web, the image is handled differently, no cleanup needed
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _processCheckIn() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      await attendanceProvider.checkIn(
        userId,
        context: context,
        // Optional: Add location if available
        // latitude: currentLocation?.latitude,
        // longitude: currentLocation?.longitude,
      );

      if (!mounted) return;

      // Success animation
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFaceLocked = false;
        _isProcessing = false;
      });
      _lockController.reverse();
      _showError(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00D4FF),
                Color(0xFF9D4EDD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.checkInSuccessful.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF000000),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirm.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF006E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _faceDetectionTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _lockController.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.black,
      body: _isInitializing
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF00D4FF),
              ),
            )
          : _cameraController == null ||
                  !_cameraController!.value.isInitialized
              ? Center(
                  child: Text(
                    'Camera not available',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // Full screen camera preview
                    Positioned.fill(
                      child: CameraPreview(_cameraController!),
                    ),
                    
                    // Dark overlay with gradient vignette
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Futuristic Scanner Widget
                    Center(
                      child: FuturisticScannerWidget(
                        detectedFaces: _detectedFaces,
                        cameraController: _cameraController!,
                        isFaceDetected: _isFaceDetected,
                        isFaceLocked: _isFaceLocked,
                        pulseAnimation: _pulseAnimation,
                        scanAnimation: _scanAnimation,
                        lockAnimation: _lockAnimation,
                      ),
                    ),
                    
                    // Glassmorphism Bottom Panel
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildGlassmorphismPanel(isDark),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGlassmorphismPanel(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                Colors.white.withOpacity(isDark ? 0.1 : 0.2),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isFaceLocked
                          ? const Color(0xFF00FF88)
                          : _isFaceDetected
                              ? const Color(0xFF00D4FF)
                              : Colors.white.withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                          color: (_isFaceLocked
                                  ? const Color(0xFF00FF88)
                                  : _isFaceDetected
                                      ? const Color(0xFF00D4FF)
                                      : Colors.transparent)
                              .withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isFaceLocked
                        ? 'LOCKED'
                        : _isFaceDetected
                            ? 'SCANNING'
                            : 'POSITION FACE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // User Name
              Text(
                _currentUserName ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Timestamp or Processing status
              if (_isProcessing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF00D4FF),
                    strokeWidth: 2,
                  ),
                )
              else if (_checkInTime != null)
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(_checkInTime!),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                )
              else
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
