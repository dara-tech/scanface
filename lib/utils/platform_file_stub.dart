// Stub file for web platform
// This file is used when dart:io is not available (web platform)

class File {
  final String path;
  File(this.path);
  
  Future<List<int>> readAsBytes() => throw UnsupportedError('File operations not supported on web');
  Future<bool> exists() => throw UnsupportedError('File operations not supported on web');
  Future<void> delete() => throw UnsupportedError('File operations not supported on web');
  Future<void> writeAsBytes(List<int> bytes) => throw UnsupportedError('File operations not supported on web');
}

class Directory {
  final String path;
  Directory(this.path);
  
  Future<bool> exists() => throw UnsupportedError('Directory operations not supported on web');
  Future<Directory> create({bool recursive = false}) => throw UnsupportedError('Directory operations not supported on web');
}
