import 'package:sqflite/sqflite.dart';
import '../models/invoice_model.dart';
import '../../core/constants/database_constants.dart';
import '../../core/utils/database_helper.dart';

class InvoiceDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(InvoiceModel invoice) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseConstants.invoicesTable,
      invoice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getInvoicesWithCompany() async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        i.${DatabaseConstants.invoiceId},
        i.${DatabaseConstants.invoiceCompanyId},
        i.${DatabaseConstants.invoiceReference},
        i.${DatabaseConstants.invoiceDate},
        i.${DatabaseConstants.invoiceNotes},
        i.${DatabaseConstants.invoiceAttachmentPaths},
        i.${DatabaseConstants.invoiceCreatedAt},
        i.${DatabaseConstants.invoiceUpdatedAt},
        c.${DatabaseConstants.companyName}
      FROM ${DatabaseConstants.invoicesTable} i
      JOIN ${DatabaseConstants.companiesTable} c 
        ON i.${DatabaseConstants.invoiceCompanyId} = c.${DatabaseConstants.companyId}
      ORDER BY i.${DatabaseConstants.invoiceDate} DESC, i.${DatabaseConstants.invoiceCreatedAt} DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getInvoicesByCompany(int companyId) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        i.${DatabaseConstants.invoiceId},
        i.${DatabaseConstants.invoiceCompanyId},
        i.${DatabaseConstants.invoiceReference},
        i.${DatabaseConstants.invoiceDate},
        i.${DatabaseConstants.invoiceNotes},
        i.${DatabaseConstants.invoiceAttachmentPaths},
        i.${DatabaseConstants.invoiceCreatedAt},
        i.${DatabaseConstants.invoiceUpdatedAt},
        c.${DatabaseConstants.companyName}
      FROM ${DatabaseConstants.invoicesTable} i
      JOIN ${DatabaseConstants.companiesTable} c 
        ON i.${DatabaseConstants.invoiceCompanyId} = c.${DatabaseConstants.companyId}
      WHERE i.${DatabaseConstants.invoiceCompanyId} = ?
      ORDER BY i.${DatabaseConstants.invoiceDate} DESC, i.${DatabaseConstants.invoiceCreatedAt} DESC
    ''', [companyId]);
  }

  Future<InvoiceModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.invoicesTable,
      where: '${DatabaseConstants.invoiceId} = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return InvoiceModel.fromMap(maps.first);
  }

  Future<List<Map<String, dynamic>>> searchInvoices(String query) async {
    final db = await _databaseHelper.database;
    
    // Use FTS for text search, then join with regular table for complete data
    return await db.rawQuery('''
      SELECT 
        i.${DatabaseConstants.invoiceId},
        i.${DatabaseConstants.invoiceCompanyId},
        i.${DatabaseConstants.invoiceReference},
        i.${DatabaseConstants.invoiceDate},
        i.${DatabaseConstants.invoiceNotes},
        i.${DatabaseConstants.invoiceAttachmentPaths},
        i.${DatabaseConstants.invoiceCreatedAt},
        i.${DatabaseConstants.invoiceUpdatedAt},
        c.${DatabaseConstants.companyName}
      FROM ${DatabaseConstants.invoicesFtsTable} fts
      JOIN ${DatabaseConstants.invoicesTable} i ON fts.rowid = i.${DatabaseConstants.invoiceId}
      JOIN ${DatabaseConstants.companiesTable} c 
        ON i.${DatabaseConstants.invoiceCompanyId} = c.${DatabaseConstants.companyId}
      WHERE ${DatabaseConstants.invoicesFtsTable} MATCH ?
      ORDER BY i.${DatabaseConstants.invoiceDate} DESC, i.${DatabaseConstants.invoiceCreatedAt} DESC
    ''', [query]);
  }

  Future<List<Map<String, dynamic>>> getInvoicesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final db = await _databaseHelper.database;
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];
    
    return await db.rawQuery('''
      SELECT 
        i.${DatabaseConstants.invoiceId},
        i.${DatabaseConstants.invoiceCompanyId},
        i.${DatabaseConstants.invoiceReference},
        i.${DatabaseConstants.invoiceDate},
        i.${DatabaseConstants.invoiceNotes},
        i.${DatabaseConstants.invoiceAttachmentPaths},
        i.${DatabaseConstants.invoiceCreatedAt},
        i.${DatabaseConstants.invoiceUpdatedAt},
        c.${DatabaseConstants.companyName}
      FROM ${DatabaseConstants.invoicesTable} i
      JOIN ${DatabaseConstants.companiesTable} c 
        ON i.${DatabaseConstants.invoiceCompanyId} = c.${DatabaseConstants.companyId}
      WHERE i.${DatabaseConstants.invoiceDate} BETWEEN ? AND ?
      ORDER BY i.${DatabaseConstants.invoiceDate} DESC, i.${DatabaseConstants.invoiceCreatedAt} DESC
    ''', [start, end]);
  }

  Future<List<Map<String, dynamic>>> getInvoicesByDate(String date) async {
    final db = await _databaseHelper.database;
    
    return await db.rawQuery('''
      SELECT 
        i.${DatabaseConstants.invoiceId},
        i.${DatabaseConstants.invoiceCompanyId},
        i.${DatabaseConstants.invoiceReference},
        i.${DatabaseConstants.invoiceDate},
        i.${DatabaseConstants.invoiceNotes},
        i.${DatabaseConstants.invoiceAttachmentPaths},
        i.${DatabaseConstants.invoiceCreatedAt},
        i.${DatabaseConstants.invoiceUpdatedAt},
        c.${DatabaseConstants.companyName}
      FROM ${DatabaseConstants.invoicesTable} i
      JOIN ${DatabaseConstants.companiesTable} c 
        ON i.${DatabaseConstants.invoiceCompanyId} = c.${DatabaseConstants.companyId}
      WHERE i.${DatabaseConstants.invoiceDate} LIKE ?
      ORDER BY i.${DatabaseConstants.invoiceDate} DESC, i.${DatabaseConstants.invoiceCreatedAt} DESC
    ''', ['$date%']);
  }

  Future<int> update(InvoiceModel invoice) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseConstants.invoicesTable,
      invoice.toMap(),
      where: '${DatabaseConstants.invoiceId} = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseConstants.invoicesTable,
      where: '${DatabaseConstants.invoiceId} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isReferenceUniqueForCompany(
    String reference, 
    int companyId, 
    {int? excludeId}
  ) async {
    final db = await _databaseHelper.database;
    String whereClause = 
        '${DatabaseConstants.invoiceReference} = ? AND ${DatabaseConstants.invoiceCompanyId} = ?';
    List<dynamic> whereArgs = [reference, companyId];
    
    if (excludeId != null) {
      whereClause += ' AND ${DatabaseConstants.invoiceId} != ?';
      whereArgs.add(excludeId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.invoicesTable,
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    return maps.isEmpty;
  }
}