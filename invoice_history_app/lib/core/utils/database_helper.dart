import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create companies table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.companiesTable} (
        ${DatabaseConstants.companyId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.companyName} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.companyPhone} TEXT,
        ${DatabaseConstants.companyEmail} TEXT,
        ${DatabaseConstants.companyAddress} TEXT,
        ${DatabaseConstants.companyTaxId} TEXT,
        ${DatabaseConstants.companyNotes} TEXT,
        ${DatabaseConstants.companyCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.companyUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Create invoices table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.invoicesTable} (
        ${DatabaseConstants.invoiceId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.invoiceCompanyId} INTEGER NOT NULL,
        ${DatabaseConstants.invoiceReference} TEXT NOT NULL,
        ${DatabaseConstants.invoiceDate} TEXT NOT NULL,
        ${DatabaseConstants.invoiceNotes} TEXT,
        ${DatabaseConstants.invoiceAttachmentPaths} TEXT,
        ${DatabaseConstants.invoiceCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.invoiceUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.invoiceCompanyId}) 
          REFERENCES ${DatabaseConstants.companiesTable} (${DatabaseConstants.companyId}) 
          ON DELETE CASCADE,
        UNIQUE(${DatabaseConstants.invoiceCompanyId}, ${DatabaseConstants.invoiceReference})
      )
    ''');

    // Create FTS virtual table for fast search
    await db.execute('''
      CREATE VIRTUAL TABLE ${DatabaseConstants.invoicesFtsTable} USING fts4(
        ${DatabaseConstants.ftsReference},
        ${DatabaseConstants.ftsNotes},
        ${DatabaseConstants.ftsCompanyName},
        content=${DatabaseConstants.invoicesTable}
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_invoices_date ON ${DatabaseConstants.invoicesTable} (${DatabaseConstants.invoiceDate})
    ''');
    
    await db.execute('''
      CREATE INDEX idx_invoices_company ON ${DatabaseConstants.invoicesTable} (${DatabaseConstants.invoiceCompanyId})
    ''');

    // Create triggers to keep FTS table in sync
    await db.execute('''
      CREATE TRIGGER invoices_fts_insert AFTER INSERT ON ${DatabaseConstants.invoicesTable}
      BEGIN
        INSERT INTO ${DatabaseConstants.invoicesFtsTable} (
          rowid, 
          ${DatabaseConstants.ftsReference}, 
          ${DatabaseConstants.ftsNotes}, 
          ${DatabaseConstants.ftsCompanyName}
        )
        SELECT 
          NEW.${DatabaseConstants.invoiceId},
          NEW.${DatabaseConstants.invoiceReference},
          COALESCE(NEW.${DatabaseConstants.invoiceNotes}, ''),
          (SELECT ${DatabaseConstants.companyName} 
           FROM ${DatabaseConstants.companiesTable} 
           WHERE ${DatabaseConstants.companyId} = NEW.${DatabaseConstants.invoiceCompanyId});
      END
    ''');

    await db.execute('''
      CREATE TRIGGER invoices_fts_delete AFTER DELETE ON ${DatabaseConstants.invoicesTable}
      BEGIN
        DELETE FROM ${DatabaseConstants.invoicesFtsTable} WHERE rowid = OLD.${DatabaseConstants.invoiceId};
      END
    ''');

    await db.execute('''
      CREATE TRIGGER invoices_fts_update AFTER UPDATE ON ${DatabaseConstants.invoicesTable}
      BEGIN
        DELETE FROM ${DatabaseConstants.invoicesFtsTable} WHERE rowid = OLD.${DatabaseConstants.invoiceId};
        INSERT INTO ${DatabaseConstants.invoicesFtsTable} (
          rowid, 
          ${DatabaseConstants.ftsReference}, 
          ${DatabaseConstants.ftsNotes}, 
          ${DatabaseConstants.ftsCompanyName}
        )
        SELECT 
          NEW.${DatabaseConstants.invoiceId},
          NEW.${DatabaseConstants.invoiceReference},
          COALESCE(NEW.${DatabaseConstants.invoiceNotes}, ''),
          (SELECT ${DatabaseConstants.companyName} 
           FROM ${DatabaseConstants.companiesTable} 
           WHERE ${DatabaseConstants.companyId} = NEW.${DatabaseConstants.invoiceCompanyId});
      END
    ''');

    // Update FTS when company name changes
    await db.execute('''
      CREATE TRIGGER company_name_fts_update AFTER UPDATE OF ${DatabaseConstants.companyName} 
      ON ${DatabaseConstants.companiesTable}
      BEGIN
        DELETE FROM ${DatabaseConstants.invoicesFtsTable} 
        WHERE rowid IN (
          SELECT ${DatabaseConstants.invoiceId} 
          FROM ${DatabaseConstants.invoicesTable} 
          WHERE ${DatabaseConstants.invoiceCompanyId} = NEW.${DatabaseConstants.companyId}
        );
        INSERT INTO ${DatabaseConstants.invoicesFtsTable} (
          rowid, 
          ${DatabaseConstants.ftsReference}, 
          ${DatabaseConstants.ftsNotes}, 
          ${DatabaseConstants.ftsCompanyName}
        )
        SELECT 
          ${DatabaseConstants.invoiceId},
          ${DatabaseConstants.invoiceReference},
          COALESCE(${DatabaseConstants.invoiceNotes}, ''),
          NEW.${DatabaseConstants.companyName}
        FROM ${DatabaseConstants.invoicesTable}
        WHERE ${DatabaseConstants.invoiceCompanyId} = NEW.${DatabaseConstants.companyId};
      END
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we just recreate the database
    if (oldVersion < newVersion) {
      // Drop all tables and recreate
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.invoicesFtsTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.invoicesTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.companiesTable}');
      await _createDB(db, newVersion);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, DatabaseConstants.dbName);
  }

  Future<void> copyDatabaseFrom(String sourcePath) async {
    final targetPath = await getDatabasePath();
    final sourceFile = File(sourcePath);
    final targetFile = File(targetPath);
    
    // Close current database
    await close();
    
    // Copy file
    await sourceFile.copy(targetPath);
    
    // Reinitialize database
    _database = await _initDB(DatabaseConstants.dbName);
  }

  Future<void> backupDatabaseTo(String targetPath) async {
    final sourcePath = await getDatabasePath();
    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);
  }
}