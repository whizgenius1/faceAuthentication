import 'package:facial_authentication/utilities/export_models.dart';
import 'package:facial_authentication/utilities/export_packages.dart';
import 'package:path/path.dart';

class UserDatabase {
  final String _databaseName = 'myDatabase.db';
  final int _databaseVersion = 1;

  final String table = 'users';
  final String columnId = 'id';
  final String columnUser = 'user';
  final String columnPassword = 'password';
  final String columnModelData = 'modelData';

  UserDatabase._privateConstructor();
  static final UserDatabase instance = UserDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDataBase();
    return _database!;
  }

  _initDataBase() async {
    return await getDatabasesPath().then((String databasePathDirectory) async {
      String databasePath = join(databasePathDirectory, _databaseName);

      // sharedPrefUtils.setString(
      //     key: sharedPrefUtils.databasePath, value: databasePath);
      return await openDatabase(databasePath,
          version: _databaseVersion,
          onConfigure: _onConfigure,
          onCreate: _onCreate);
    });
  }

  _onConfigure(Database database) async {
    // Add support for cascade delete
    await database.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database database, int version) async {
    database.execute('''
     CREATE TABLE IF NOT EXISTS $table(
      $columnId INTEGER PRIMARY KEY,
      $columnUser TEXT NOT NULL,
      $columnPassword TEXT NOT NULL,
      $columnModelData TEXT NOT NULL
     )
    ''');
  }

  Future<int> insert({required UserModel userModel}) async {
    return await instance.database.then((Database database) async =>
        await database.insert(table, userModel.toMap()));
  }

  Future<List<UserModel>> queryAllUsers() async {
    return await instance.database.then((Database database) async =>
        await database.query(table).then((value) => value.isEmpty
            ? []
            : value.map<UserModel>((e) => UserModel.fromJson(e)).toList()));
  }

  Future<void> deleteAllUsers() async {
    await instance.database
        .then((Database database) async => await database.delete(table));
  }
}
