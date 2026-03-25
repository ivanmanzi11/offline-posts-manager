import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        title TEXT,
        body TEXT
      )
    ''');
  }

  Future<int> insertPost(Post post) async {
    final db = await instance.database;
    return db.insert('posts', post.toMap());
  }

  Future<List<Post>> getPosts() async {
    final db = await instance.database;
    final result = await db.query('posts');
    return result.map((e) => Post.fromMap(e)).toList();
  }

  Future<int> updatePost(Post post) async {
    final db = await instance.database;
    return db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await instance.database;
    return db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}