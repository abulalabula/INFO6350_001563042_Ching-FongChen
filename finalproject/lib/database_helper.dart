import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const sql = '''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price TEXT NOT NULL,
        image TEXT  -- Column to store Base64 encoded images
      );
    ''';
    await db.execute(sql);
  }
    // Add to SQLite
  Future<int> addPost(Map<String, dynamic> postData) async {
    final db = await database;
    int id = await db.insert('posts', postData);

    // Add to Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(id.toString())
        .set(postData);
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final db = await database;
    final result = await db.query('posts');
    return result;
  }

  Future<Map<String, dynamic>> fetchPostById(int id) async {
    final db = await database;
    final results = await db.query('posts', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<void> updatePost(int id, Map<String, dynamic> postData) async {
    final db = await database;
    await db.update('posts', postData, where: 'id = ?', whereArgs: [id]);

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(id.toString())
        .update(postData);
  }

  Future<void> deletePost(int id) async {
    final db = await database;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(id.toString())
        .delete();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
