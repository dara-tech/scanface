import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/face_embedding_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite database is not supported on web. '
        'Please use the mobile app for full functionality, or implement a web-compatible database solution.'
      );
    }
    
    if (_database != null) return _database!;
    _database = await _initDB('${AppConstants.databaseName}');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT,
        role TEXT NOT NULL,
        department TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        profile_image_path TEXT
      )
    ''');

    // Face embeddings table
    await db.execute('''
      CREATE TABLE face_embeddings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        embedding TEXT NOT NULL,
        image_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        check_in_time TEXT,
        check_out_time TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, date)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_attendance_user_date ON attendance(user_id, date)');
    await db.execute('CREATE INDEX idx_face_embeddings_user ON face_embeddings(user_id)');
  }

  // User operations
  Future<String> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return user.id;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at DESC');

    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Face embedding operations
  Future<String> insertFaceEmbedding(FaceEmbedding embedding) async {
    final db = await database;
    await db.insert('face_embeddings', embedding.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return embedding.id;
  }

  Future<List<FaceEmbedding>> getFaceEmbeddingsByUserId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'face_embeddings',
      where: 'user_id = ? AND is_active = ?',
      whereArgs: [userId, 1],
    );

    return maps.map((map) => FaceEmbedding.fromMap(map)).toList();
  }

  Future<List<FaceEmbedding>> getAllFaceEmbeddings() async {
    final db = await database;
    final maps = await db.query(
      'face_embeddings',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    return maps.map((map) => FaceEmbedding.fromMap(map)).toList();
  }

  Future<int> deactivateFaceEmbedding(String id) async {
    final db = await database;
    return await db.update(
      'face_embeddings',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Attendance operations
  Future<String> insertAttendance(Attendance attendance) async {
    final db = await database;
    await db.insert('attendance', attendance.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return attendance.id;
  }

  Future<Attendance?> getTodayAttendance(String userId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final maps = await db.query(
      'attendance',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, today],
    );

    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Attendance>> getAttendanceByUserId(String userId, {DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String where = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final maps = await db.query(
      'attendance',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<List<Attendance>> getAllAttendance({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final maps = await db.query(
      'attendance',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
