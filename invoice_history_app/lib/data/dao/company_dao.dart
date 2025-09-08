import 'package:sqflite/sqflite.dart';
import '../models/company_model.dart';
import '../../core/constants/database_constants.dart';
import '../../core/utils/database_helper.dart';

class CompanyDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(CompanyModel company) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseConstants.companiesTable,
      company.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CompanyModel>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.companiesTable,
      orderBy: '${DatabaseConstants.companyName} ASC',
    );
    
    return List.generate(maps.length, (i) {
      return CompanyModel.fromMap(maps[i]);
    });
  }

  Future<CompanyModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.companiesTable,
      where: '${DatabaseConstants.companyId} = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return CompanyModel.fromMap(maps.first);
  }

  Future<List<CompanyModel>> search(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.companiesTable,
      where: '${DatabaseConstants.companyName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${DatabaseConstants.companyName} ASC',
    );
    
    return List.generate(maps.length, (i) {
      return CompanyModel.fromMap(maps[i]);
    });
  }

  Future<int> update(CompanyModel company) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseConstants.companiesTable,
      company.toMap(),
      where: '${DatabaseConstants.companyId} = ?',
      whereArgs: [company.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseConstants.companiesTable,
      where: '${DatabaseConstants.companyId} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isNameUnique(String name, {int? excludeId}) async {
    final db = await _databaseHelper.database;
    String whereClause = '${DatabaseConstants.companyName} = ?';
    List<dynamic> whereArgs = [name];
    
    if (excludeId != null) {
      whereClause += ' AND ${DatabaseConstants.companyId} != ?';
      whereArgs.add(excludeId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.companiesTable,
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    return maps.isEmpty;
  }
}