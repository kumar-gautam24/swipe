// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../config/app_config.dart';
// import '../models/product_model.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// class DBService {
//   static Database? _database;

//   static Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   static Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), AppConfig.dbName);
//     return await openDatabase(
//       path,
//       version: AppConfig.dbVersion,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE products (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             product_name TEXT NOT NULL,
//             product_type TEXT NOT NULL,
//             price REAL NOT NULL,
//             tax REAL NOT NULL,
//             image TEXT,
//             is_synced INTEGER DEFAULT 0,
//             created_at TEXT DEFAULT CURRENT_TIMESTAMP
//           )
//         ''');
//       },
//     );
//   }

//   static Future<int> insertProduct(Product product) async {
//     final db = await database;
//     return await db.insert(
//       'products',
//       product.toJson(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   static Future<List<Product>> getProducts({String? searchQuery}) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps;

//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       maps = await db.query(
//         'products',
//         where: 'product_name LIKE ?',
//         whereArgs: ['%$searchQuery%'],
//         orderBy: 'created_at DESC',
//       );
//     } else {
//       maps = await db.query('products', orderBy: 'created_at DESC');
//     }

//     return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
//   }

//   static Future<List<Product>> getUnsyncedProducts() async {
//     final db = await database;
//     final maps = await db.query(
//       'products',
//       where: 'is_synced = ?',
//       whereArgs: [0],
//     );
//     return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
//   }

//   static Future<void> markAsSynced(int id) async {
//     final db = await database;
//     await db.update(
//       'products',
//       {'is_synced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   static Future<void> deleteProduct(int id) async {
//     final db = await database;
//     await db.delete(
//       'products',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
