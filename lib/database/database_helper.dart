import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/lead.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'leads.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL,
        notes TEXT,
        status INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  Future<Lead> create(Lead lead) async {
    final db = await instance.database;
    final id = await db.insert('leads', lead.toMap());
    return lead.copyWith(id: id);
  }

  Future<List<Lead>> readAll() async {
    final db = await instance.database;
    final result = await db.query('leads', orderBy: 'createdAt DESC');
    return result.map((json) => Lead.fromMap(json)).toList();
  }

  Future<Lead> updateLead(Lead lead) async {
    final db = await instance.database;
    await db.update('leads', lead.toMap(), where: 'id = ?', whereArgs: [lead.id]);
    return lead;
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('leads', where: 'id = ?', whereArgs: [id]);
  }
}