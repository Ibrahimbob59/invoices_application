import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import 'home_screen.dart';
import 'invoices_screen.dart';
import 'company_screen.dart';
import 'backup_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InvoicesScreen(),
    const CompanyScreen(),
    const BackupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Invoice History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'سجل الفواتير',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: AppStrings.home,
              titleArabic: AppStrings.homeArabic,
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.receipt_long,
              title: AppStrings.invoices,
              titleArabic: AppStrings.invoicesArabic,
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.business,
              title: AppStrings.insertNewCompany,
              titleArabic: AppStrings.insertNewCompanyArabic,
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.backup,
              title: AppStrings.exportImportDatabase,
              titleArabic: AppStrings.exportImportDatabaseArabic,
              index: 3,
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String titleArabic,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(
            titleArabic,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppStrings.home;
      case 1:
        return AppStrings.invoices;
      case 2:
        return AppStrings.insertNewCompany;
      case 3:
        return AppStrings.exportImportDatabase;
      default:
        return AppStrings.home;
    }
  }
}