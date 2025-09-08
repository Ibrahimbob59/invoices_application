class AppConstants {
  static const String appName = 'Invoice History';
  static const String appNameArabic = 'سجل الفواتير';
  
  // Backup file constants
  static const String backupPrefix = 'InvoiceHistory_backup_';
  static const String backupSuffix = '.db';
  static const String preRestoreSuffix = '_preRestore';
  
  // Search debounce delay
  static const Duration searchDebounceDelay = Duration(milliseconds: 200);
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM d, yyyy';
  static const String backupDateFormat = 'yyyy-MM-dd_HH-mm-ss';
}