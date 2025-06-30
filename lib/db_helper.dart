import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'film_model.dart';
import 'comment_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'films.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE films (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        genre TEXT,
        posterPath TEXT, -- ✅ poster disimpan sebagai path lokal
        rating REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filmId TEXT,
        content TEXT,
        author TEXT,
        createdAt TEXT,
        likes INTEGER DEFAULT 0,
        parentId INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE films ADD COLUMN rating REAL DEFAULT 0.0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE comments ADD COLUMN createdAt TEXT');
      await db.execute(
        'ALTER TABLE comments ADD COLUMN likes INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE comments ADD COLUMN parentId INTEGER');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE films RENAME TO old_films');

      await db.execute('''
        CREATE TABLE films (
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          genre TEXT,
          posterPath TEXT,
          rating REAL DEFAULT 0.0
        )
      ''');

      await db.execute('''
        INSERT INTO films (id, title, description, genre, posterPath, rating)
        SELECT id, title, description, genre, posterPath, rating FROM old_films
      ''');

      await db.execute('DROP TABLE old_films');
    }
  }

  // ===================== FILM =====================

  Future<int> insertFilm(Film film) async {
    final db = await database;
    try {
      return await db.insert(
        'films',
        film.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting film: $e');
      return -1;
    }
  }

  Future<int> updateFilm(Film film) async {
    final db = await database;
    try {
      return await db.update(
        'films',
        film.toMap(),
        where: 'id = ?',
        whereArgs: [film.id],
      );
    } catch (e) {
      print('❌ Error updating film: $e');
      return -1;
    }
  }

  Future<int> deleteFilm(String id) async {
    final db = await database;
    try {
      return await db.delete('films', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting film: $e');
      return -1;
    }
  }

  Future<List<Film>> getAllFilms() async {
    final db = await database;
    try {
      final maps = await db.query('films');
      return maps.map((map) => Film.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error fetching films: $e');
      return [];
    }
  }

  Future<Film?> getFilmById(String id) async {
    final db = await database;
    try {
      final maps = await db.query('films', where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return Film.fromMap(maps.first);
      }
    } catch (e) {
      print('❌ Error fetching film by ID: $e');
    }
    return null;
  }

  Future<void> clearAllFilms() async {
    final db = await database;
    try {
      await db.delete('films');
    } catch (e) {
      print('❌ Error clearing films: $e');
    }
  }

  // ===================== COMMENT =====================

  Future<void> insertComment(Comment comment) async {
    final db = await database;
    try {
      await db.insert('comments', comment.toMap());
    } catch (e) {
      print('❌ Error inserting comment: $e');
    }
  }

  Future<List<Comment>> getCommentsByFilmId(String filmId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'comments',
        where: 'filmId = ?',
        whereArgs: [filmId],
      );
      return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error fetching comments: $e');
      return [];
    }
  }

  Future<List<Comment>> getCommentsByFilmIdSorted(
    String filmId,
    String sortBy,
  ) async {
    final db = await database;
    String orderBy = 'createdAt DESC'; // Default to latest

    if (sortBy == 'oldest') {
      orderBy = 'createdAt ASC';
    } else if (sortBy == 'hottest') {
      orderBy = 'likes DESC';
    }

    try {
      final maps = await db.query(
        'comments',
        where: 'filmId = ? AND parentId IS NULL',
        whereArgs: [filmId],
        orderBy: orderBy,
      );
      return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error fetching sorted comments: $e');
      return [];
    }
  }

  Future<List<Comment>> getReplies(int parentId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'comments',
        where: 'parentId = ?',
        whereArgs: [parentId],
        orderBy: 'createdAt ASC',
      );
      return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error fetching replies: $e');
      return [];
    }
  }

  Future<void> updateComment(Comment comment) async {
    final db = await database;
    try {
      await db.update(
        'comments',
        comment.toMap(),
        where: 'id = ?',
        whereArgs: [comment.id],
      );
    } catch (e) {
      print('❌ Error updating comment: $e');
    }
  }

  Future<void> deleteComment(int id) async {
    final db = await database;
    try {
      await db.delete('comments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting comment: $e');
    }
  }
}
