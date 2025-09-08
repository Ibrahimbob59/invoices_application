import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../application/providers/company_provider.dart';
import '../../domain/entities/company.dart';
import '../widgets/company_form_dialog.dart';

class CompanyScreen extends ConsumerWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noCompaniesYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.noCompaniesYetArabic,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCompanyForm(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Company'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(companiesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.business,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      company.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (company.phone != null && company.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(company.phone!),
                              ],
                            ),
                          ),
                        if (company.email != null && company.email!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    company.email!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (company.address != null && company.address!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    company.address!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showCompanyForm(context, ref, company: company);
                            break;
                          case 'delete':
                            _deleteCompany(context, ref, company);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text(AppStrings.edit),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(companiesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCompanyForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCompanyForm(BuildContext context, WidgetRef ref, {Company? company}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompanyFormDialog(
          company: company,
          onSaved: (savedCompany) {
            // The dialog handles saving through the provider
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _deleteCompany(BuildContext context, WidgetRef ref, Company company) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.confirmDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.confirmDeleteArabic),
              const SizedBox(height: 8),
              Text('Company: ${company.name}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final operations = ref.read(companyOperationsProvider);
                final success = await operations.deleteCompany(company.id!);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Company deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete company')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
  }
}