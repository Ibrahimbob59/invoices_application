import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../application/providers/invoice_provider.dart';
import '../widgets/invoice_list_item.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(invoiceSearchResultsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Text Search
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.searchInvoices} / ${AppStrings.searchInvoicesArabic}',
                    hintText: 'Search by reference, notes, or company name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                
                // Date Filter
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.date} Filter / تصفية ${AppStrings.dateArabic}',
                    hintText: 'Filter by date (YYYY-MM-DD)',
                    prefixIcon: const Icon(Icons.date_range),
                    suffixIcon: _dateController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearDateFilter,
                          )
                        : IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDateFilter,
                          ),
                  ),
                  onTap: _selectDateFilter,
                ),
              ],
            ),
          ),
          
          // Results List
          Expanded(
            child: searchResults.when(
              data: (invoices) {
                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.noInvoicesYet,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.noInvoicesYetArabic,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return InvoiceListItem(
                        invoice: invoice,
                        onTap: () => _showInvoiceDetails(context, invoice),
                        onEdit: () => _editInvoice(invoice),
                        onDelete: () => _deleteInvoice(invoice),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                      onPressed: () => ref.refresh(invoiceSearchResultsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid too frequent updates
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(invoiceSearchQueryProvider.notifier).state = query;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(invoiceSearchQueryProvider.notifier).state = '';
  }

  Future<void> _selectDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _dateController.text = formattedDate;
      ref.read(invoiceDateFilterProvider.notifier).state = formattedDate;
    }
  }

  void _clearDateFilter() {
    _dateController.clear();
    ref.read(invoiceDateFilterProvider.notifier).state = null;
  }

  Future<void> _onRefresh() async {
    ref.refresh(invoiceSearchResultsProvider);
  }

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${AppStrings.reference}: ${invoice['reference']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(AppStrings.company, invoice['company_name']),
                _buildDetailRow(AppStrings.date, invoice['date']),
                if (invoice['notes'] != null && invoice['notes'].toString().isNotEmpty)
                  _buildDetailRow(AppStrings.notes, invoice['notes']),
                if (invoice['attachment_paths'] != null)
                  _buildDetailRow(AppStrings.attachments, 'Has attachments'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editInvoice(invoice);
              },
              child: const Text(AppStrings.edit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  void _editInvoice(Map<String, dynamic> invoice) {
    // Navigate to edit screen (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality will be implemented')),
    );
  }

  void _deleteInvoice(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.confirmDelete),
          content: const Text(AppStrings.confirmDeleteArabic),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final operations = ref.read(invoiceOperationsProvider);
                final success = await operations.deleteInvoice(invoice['id']);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete invoice')),
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