import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Platform-agnostic file operations
abstract class PlatformFile {
  static Future<Uint8List> readAsBytes(String path) async {
    if (kIsWeb) {
      // For web, we'll need to handle this differently
      // This is a placeholder - actual implementation would use browser APIs
      throw UnsupportedError('File reading not supported on web. Use image picker instead.');
    } else {
      // ignore: avoid_relative_lib_imports
      final file = await _getFile(path);
      return await file.readAsBytes();
    }
  }

  static Future<bool> exists(String path) async {
    if (kIsWeb) {
      return false; // Files don't exist in the same way on web
    } else {
      // ignore: avoid_relative_lib_imports
      final file = await _getFile(path);
      return await file.exists();
    }
  }

  static Future<void> delete(String path) async {
    if (kIsWeb) {
      // No-op on web
      return;
    } else {
      // ignore: avoid_relative_lib_imports
      final file = await _getFile(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<void> writeAsBytes(String path, Uint8List bytes) async {
    if (kIsWeb) {
      throw UnsupportedError('File writing not supported on web. Use browser storage instead.');
    } else {
      // ignore: avoid_relative_lib_imports
      final file = await _getFile(path);
      await file.writeAsBytes(bytes);
    }
  }

  static dynamic _getFile(String path) {
    // ignore: avoid_relative_lib_imports
    return _FileImpl(path);
  }
}

// Conditional import implementation
// ignore: uri_does_not_exist
import 'dart:io' if (dart.library.html) 'platform_file_stub.dart' as io;

class _FileImpl {
  final String path;
  _FileImpl(this.path);

  Future<Uint8List> readAsBytes() => io.File(path).readAsBytes();
  Future<bool> exists() => io.File(path).exists();
  Future<void> delete() => io.File(path).delete();
  Future<void> writeAsBytes(Uint8List bytes) => io.File(path).writeAsBytes(bytes);
}
