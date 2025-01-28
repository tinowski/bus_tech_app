import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// This class handles creating the DB, opening connections, etc.
class TimesheetDatabase {
  static final TimesheetDatabase instance = TimesheetDatabase._init();

  static Database? _database;

  TimesheetDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('timesheet.db');
    return _database!;
  }

  // Create or open the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create a table to store timesheet data
    await db.execute('''
    CREATE TABLE timesheet (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      clock_in TEXT,
      clock_out TEXT
    )
    ''');
  }

  // Insert or update a timesheet record
  // We'll keep a simple approach: one record per date
  Future<void> upsertTimesheet({
    required String date,
    String? clockIn,
    String? clockOut,
  }) async {
    final db = await instance.database;

    // We try to find if there's already a record for this date
    final res = await db.query(
      'timesheet',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (res.isEmpty) {
      // Insert new record
      await db.insert('timesheet', {
        'date': date,
        'clock_in': clockIn,
        'clock_out': clockOut,
      });
    } else {
      // Update existing record
      await db.update(
        'timesheet',
        {
          'clock_in': clockIn,
          'clock_out': clockOut,
        },
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }

  // Get a timesheet record by date
  Future<Map<String, dynamic>?> getTimesheetByDate(String date) async {
    final db = await instance.database;

    final res = await db.query(
      'timesheet',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  // Close DB if needed
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
