import '../entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> getAllCompanies();
  Future<Company?> getCompanyById(int id);
  Future<List<Company>> searchCompanies(String query);
  Future<int> createCompany(Company company);
  Future<bool> updateCompany(Company company);
  Future<bool> deleteCompany(int id);
  Future<bool> isNameUnique(String name, {int? excludeId});
}