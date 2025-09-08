class DatabaseConstants {
  static const String dbName = 'invoice_history.db';
  static const int dbVersion = 1;
  
  // Tables
  static const String companiesTable = 'companies';
  static const String invoicesTable = 'invoices';
  static const String invoicesFtsTable = 'invoices_fts';
  
  // Company table columns
  static const String companyId = 'id';
  static const String companyName = 'name';
  static const String companyPhone = 'phone';
  static const String companyEmail = 'email';
  static const String companyAddress = 'address';
  static const String companyTaxId = 'tax_id';
  static const String companyNotes = 'notes';
  static const String companyCreatedAt = 'created_at';
  static const String companyUpdatedAt = 'updated_at';
  
  // Invoice table columns
  static const String invoiceId = 'id';
  static const String invoiceCompanyId = 'company_id';
  static const String invoiceReference = 'reference';
  static const String invoiceDate = 'date';
  static const String invoiceNotes = 'notes';
  static const String invoiceAttachmentPaths = 'attachment_paths';
  static const String invoiceCreatedAt = 'created_at';
  static const String invoiceUpdatedAt = 'updated_at';
  
  // FTS columns
  static const String ftsRowId = 'rowid';
  static const String ftsReference = 'reference';
  static const String ftsNotes = 'notes';
  static const String ftsCompanyName = 'company_name';
}