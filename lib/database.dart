import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Ініціалізація бази даних
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'expense_tracker.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            type TEXT,
            amount REAL,
            currency TEXT,
            date TEXT,
            description TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _database!;
  }

  // Додавання нового користувача
  static Future<int> addUser(String username, String email, String password) async {
    final db = await getDatabase();
    return await db.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Перевірка існування користувача за email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Оновлення пароля користувача
  static Future<int> updatePassword(int id, String newPassword) async {
    final db = await getDatabase();
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Додавання запису (витрати або прибутки)
  static Future<int> addRecord(
      int userId,
      String type,
      double amount,
      String currency,
      String date,
      String description,
      ) async {
    final db = await getDatabase();
    return await db.insert(
      'records',
      {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'currency': currency,
        'date': date,
        'description': description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Завантаження всіх записів для конкретного користувача
  static Future<List<Map<String, dynamic>>> getUserRecords(int userId) async {
    final db = await getDatabase();
    return await db.query(
      'records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // Видалення запису за його ID
  static Future<int> deleteRecord(int id) async {
    final db = await getDatabase();
    return await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Закриття бази даних
  static Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
    _database = null;
  }
}
