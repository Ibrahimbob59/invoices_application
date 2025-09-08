import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../../data/repositories/company_repository_impl.dart';

// Repository provider
final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl();
});

// All companies provider
final companiesProvider = FutureProvider<List<Company>>((ref) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getAllCompanies();
});

// Selected company provider
final selectedCompanyProvider = StateProvider<Company?>((ref) => null);

// Company search query provider
final companySearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered companies provider based on search
final filteredCompaniesProvider = Provider<AsyncValue<List<Company>>>((ref) {
  final companiesAsync = ref.watch(companiesProvider);
  final searchQuery = ref.watch(companySearchQueryProvider);
  
  return companiesAsync.when(
    data: (companies) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(companies);
      }
      final filtered = companies.where((company) =>
        company.name.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Company operations provider
final companyOperationsProvider = Provider((ref) => CompanyOperations(ref));

class CompanyOperations {
  final Ref _ref;
  
  CompanyOperations(this._ref);
  
  Future<bool> createCompany(Company company) async {
    final repository = _ref.read(companyRepositoryProvider);
    try {
      final id = await repository.createCompany(company);
      // Refresh companies list
      _ref.invalidate(companiesProvider);
      return id > 0;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateCompany(Company company) async {
    final repository = _ref.read(companyRepositoryProvider);
    try {
      final success = await repository.updateCompany(company);
      if (success) {
        // Refresh companies list
        _ref.invalidate(companiesProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteCompany(int id) async {
    final repository = _ref.read(companyRepositoryProvider);
    try {
      final success = await repository.deleteCompany(id);
      if (success) {
        // Refresh companies list
        _ref.invalidate(companiesProvider);
        // Clear selected company if it was the deleted one
        final selected = _ref.read(selectedCompanyProvider);
        if (selected?.id == id) {
          _ref.read(selectedCompanyProvider.notifier).state = null;
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isNameUnique(String name, {int? excludeId}) async {
    final repository = _ref.read(companyRepositoryProvider);
    return await repository.isNameUnique(name, excludeId: excludeId);
  }
}