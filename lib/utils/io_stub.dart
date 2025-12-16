// Stub file for web platform - replaces dart:io when running on web

class File {
  final String path;
  File(this.path);
  
  Future<List<int>> readAsBytes() => throw UnsupportedError('File.readAsBytes not supported on web');
  Future<bool> exists() => throw UnsupportedError('File.exists not supported on web');
  Future<void> delete() => throw UnsupportedError('File.delete not supported on web');
  Future<void> writeAsBytes(List<int> bytes) => throw UnsupportedError('File.writeAsBytes not supported on web');
}

class Directory {
  final String path;
  Directory(this.path);
  
  Future<bool> exists() => throw UnsupportedError('Directory.exists not supported on web');
  Future<Directory> create({bool recursive = false}) => throw UnsupportedError('Directory.create not supported on web');
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
}
