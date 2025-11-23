import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter database, jika belum ada maka inisialisasi
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('remindy.db');
    return _database!;
  }

  // Membuka koneksi database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Membuat tabel saat pertama kali aplikasi dijalankan
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // SQLite menggunakan 0/1
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textType,
        deadline $textType,
        category $textType,
        priority $intType,
        is_reminder_active $boolType,
        is_completed $boolType
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // 1. Create (Tambah Tugas)
  Future<int> createTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // 2. Read All (Ambil Semua Tugas)
  Future<List<TaskModel>> readAllTasks() async {
    final db = await instance.database;
    // Mengurutkan berdasarkan deadline terdekat
    final result = await db.query('tasks', orderBy: 'deadline ASC');
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  // 3. Update (Edit Tugas / Tandai Selesai)
  Future<int> updateTask(TaskModel task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 4. Delete (Hapus Tugas)
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 5. Close Database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}