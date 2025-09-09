import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/database_helper.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Export Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.exportDatabase,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppStrings.exportDatabaseArabic,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create a backup of your invoice database that you can save or share.',
                      style: TextStyle(fontSize: 14),
                      
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قم بإنشاء نسخة احتياطية من قاعدة بيانات الفواتير يمكنك حفظها أو مشاركتها.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isBackingUp ? null : _exportDatabase,
                        icon: _isBackingUp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.backup),
                        label: Text(_isBackingUp ? 'Creating Backup...' : AppStrings.backup),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Import Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_download,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.importDatabase,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppStrings.importDatabaseArabic,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Restore your data from a previously created backup file. This will replace your current data.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'استعادة البيانات من ملف النسخة الاحتياطية. سيتم استبدال البيانات الحالية.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRestoring ? null : _importDatabase,
                        icon: _isRestoring
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.restore),
                        label: Text(_isRestoring ? 'Restoring...' : AppStrings.restore),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Backup files are saved with timestamp for easy identification. Keep your backups safe and secure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ملفات النسخ الاحتياطي محفوظة بالوقت والتاريخ للتعرف عليها بسهولة. احتفظ بنسخك الاحتياطية آمنة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                      
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportDatabase() async {
    if (!mounted) return;
    
    setState(() {
      _isBackingUp = true;
    });

    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(directory.path, 'backups'));
      
      // Create backups directory if it doesn't exist
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }

      // Create backup filename with timestamp
      final timestamp = DateFormat(AppConstants.backupDateFormat).format(DateTime.now());
      final backupFileName = '${AppConstants.backupPrefix}$timestamp${AppConstants.backupSuffix}';
      final backupPath = path.join(backupDir.path, backupFileName);

      // Copy database to backup location
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.backupDatabaseTo(backupPath);

      // Share the backup file
      final result = await Share.shareXFiles(
        [XFile(backupPath)],
        text: 'Invoice History Database Backup - $timestamp',
        subject: 'Invoice History Backup',
      );

      if (result.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.backupSuccess)),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.backupError}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _importDatabase() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.confirmRestore),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.confirmRestoreArabic),
              SizedBox(height: 16),
              Text(
                'This action cannot be undone. Your current data will be backed up before restoration.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(AppStrings.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      _isRestoring = true;
    });

    try {
      // Pick backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
        dialogTitle: 'Select backup file to restore',
      );

      if (result == null) {
        if (mounted) {
          setState(() {
            _isRestoring = false;
          });
        }
        return;
      }

      final filePath = result.files.single.path!;
      
      // Create pre-restore backup
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(directory.path, 'backups'));
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }
      
      final timestamp = DateFormat(AppConstants.backupDateFormat).format(DateTime.now());
      final preRestoreBackupPath = path.join(
        backupDir.path, 
        '${AppConstants.backupPrefix}$timestamp${AppConstants.preRestoreSuffix}${AppConstants.backupSuffix}'
      );

      final dbHelper = DatabaseHelper.instance;
      await dbHelper.backupDatabaseTo(preRestoreBackupPath);

      // Restore from selected file
      await dbHelper.copyDatabaseFrom(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.restoreSuccess)),
        );

        // Refresh all providers to reflect the restored data
        _refreshAllProviders();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.restoreError}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  void _refreshAllProviders() {
    // Import the providers you need to refresh
    // ref.refresh(companiesProvider);
    // ref.refresh(invoicesWithCompanyProvider);
    // This would typically be done by invalidating providers or using a global refresh mechanism
  }
}