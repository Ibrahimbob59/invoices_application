import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../data/repositories/invoice_repository_impl.dart';

// Repository provider
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl();
});

// All invoices with company data provider
final invoicesWithCompanyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(invoiceRepositoryProvider);
  return await repository.getAllInvoicesWithCompany();
});

// Selected company invoices provider
final companyInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, companyId) async {
  final repository = ref.read(invoiceRepositoryProvider);
  return await repository.getInvoicesByCompany(companyId);
});

// Invoice search providers
final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');
final invoiceDateFilterProvider = StateProvider<String?>((ref) => null);

// Search results provider with debouncing
final invoiceSearchResultsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(invoiceRepositoryProvider);
  final searchQuery = ref.watch(invoiceSearchQueryProvider);
  final dateFilter = ref.watch(invoiceDateFilterProvider);
  
  // If there's a date filter, apply it
  if (dateFilter != null && dateFilter.isNotEmpty) {
    return await repository.getInvoicesByDate(dateFilter);
  }
  
  // If there's a search query, use FTS search
  if (searchQuery.isNotEmpty) {
    return await repository.searchInvoices(searchQuery);
  }
  
  // Otherwise return all invoices
  return await repository.getAllInvoicesWithCompany();
});

// Invoice form providers
final invoiceFormProvider = StateNotifierProvider<InvoiceFormNotifier, InvoiceFormState>((ref) {
  return InvoiceFormNotifier();
});

class InvoiceFormState {
  final int? companyId;
  final String reference;
  final DateTime date;
  final String notes;
  final List<String> attachmentPaths;
  final bool isLoading;
  final String? errorMessage;

  const InvoiceFormState({
    this.companyId,
    this.reference = '',
    required this.date,
    this.notes = '',
    this.attachmentPaths = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  InvoiceFormState copyWith({
    int? companyId,
    String? reference,
    DateTime? date,
    String? notes,
    List<String>? attachmentPaths,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InvoiceFormState(
      companyId: companyId ?? this.companyId,
      reference: reference ?? this.reference,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class InvoiceFormNotifier extends StateNotifier<InvoiceFormState> {
  InvoiceFormNotifier() : super(InvoiceFormState(date: DateTime.now()));

  void updateCompanyId(int? companyId) {
    state = state.copyWith(companyId: companyId);
  }

  void updateReference(String reference) {
    state = state.copyWith(reference: reference);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void addAttachment(String path) {
    final updatedPaths = List<String>.from(state.attachmentPaths)..add(path);
    state = state.copyWith(attachmentPaths: updatedPaths);
  }

  void removeAttachment(String path) {
    final updatedPaths = List<String>.from(state.attachmentPaths)..remove(path);
    state = state.copyWith(attachmentPaths: updatedPaths);
  }

  void clearForm() {
    state = InvoiceFormState(date: DateTime.now());
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

// Invoice operations provider
final invoiceOperationsProvider = Provider((ref) => InvoiceOperations(ref));

class InvoiceOperations {
  final Ref _ref;
  
  InvoiceOperations(this._ref);
  
  Future<bool> createInvoice(Invoice invoice) async {
    final repository = _ref.read(invoiceRepositoryProvider);
    try {
      final id = await repository.createInvoice(invoice);
      // Refresh invoices lists
      _ref.invalidate(invoicesWithCompanyProvider);
      _ref.invalidate(invoiceSearchResultsProvider);
      return id > 0;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateInvoice(Invoice invoice) async {
    final repository = _ref.read(invoiceRepositoryProvider);
    try {
      final success = await repository.updateInvoice(invoice);
      if (success) {
        // Refresh invoices lists
        _ref.invalidate(invoicesWithCompanyProvider);
        _ref.invalidate(invoiceSearchResultsProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteInvoice(int id) async {
    final repository = _ref.read(invoiceRepositoryProvider);
    try {
      final success = await repository.deleteInvoice(id);
      if (success) {
        // Refresh invoices lists
        _ref.invalidate(invoicesWithCompanyProvider);
        _ref.invalidate(invoiceSearchResultsProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isReferenceUniqueForCompany(String reference, int companyId, {int? excludeId}) async {
    final repository = _ref.read(invoiceRepositoryProvider);
    return await repository.isReferenceUniqueForCompany(reference, companyId, excludeId: excludeId);
  }
}