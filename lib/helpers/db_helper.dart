import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course_model.dart';

class DBHelper {
  static const String _dbName = 'courses.db';
  static const int _dbVersion = 1;

  // جدول الكورسات الرئيسي
  static const String _coursesTable = 'courses';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // إنشاء جدول الكورسات الرئيسي
    await db.execute('''
      CREATE TABLE $_coursesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        price REAL,
        photo TEXT,
        video TEXT,
        isFavorite INTEGER DEFAULT 0,
        isInCart INTEGER DEFAULT 0
      )
    ''');
  }

  // إضافة كورس جديد إلى قاعدة البيانات
  Future<int> addCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.insert(_coursesTable, course);
  }

  // جلب جميع الكورسات
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await database;
    return await db.query(_coursesTable);
  }

  // تحديث حالة المفضلة
  Future<int> updateFavoriteStatus(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      _coursesTable,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // تحديث حالة السلة
  Future<int> updateCartStatus(int id, bool isInCart) async {
    final db = await database;
    return await db.update(
      _coursesTable,
      {'isInCart': isInCart ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // إضافة كورس إلى المفضلة
  Future<void> insertToFavorites(dynamic id) async {
    await updateFavoriteStatus(id, true);
  }

  // إضافة كورس إلى السلة
  Future<void> insertToCart(dynamic id) async {
    await updateCartStatus(id, true);
  }

  // حذف كورس من المفضلة
  Future<void> deleteFromFavorites(int id) async {
    await updateFavoriteStatus(id, false);
  }

  // حذف كورس من السلة
  Future<void> deleteFromCart(int id) async {
    await updateCartStatus(id, false);
  }

  // جلب الكورسات المفضلة
  Future<List<Course>> getFavorites() async {
    final db = await database;
    final result = await db.query(
      _coursesTable,
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return result.map((json) => Course.fromJson(json)).toList();
  }

  // جلب الكورسات الموجودة في السلة
  Future<List<Course>> getCart() async {
    final db = await database;
    final result = await db.query(
      _coursesTable,
      where: 'isInCart = ?',
      whereArgs: [1],
    );
    return result.map((json) => Course.fromJson(json)).toList();
  }

  // حذف كورس من قاعدة البيانات
  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete(_coursesTable, where: 'id = ?', whereArgs: [id]);
  }

  // مسح جميع الكورسات من المفضلة
  Future<void> clearFavorites() async {
    final db = await database;
    await db.update(
      _coursesTable,
      {'isFavorite': 0},
    );
  }

  // مسح جميع الكورسات من السلة
  Future<void> clearCart() async {
    final db = await database;
    await db.update(
      _coursesTable,
      {'isInCart': 0},
    );
  }
}
