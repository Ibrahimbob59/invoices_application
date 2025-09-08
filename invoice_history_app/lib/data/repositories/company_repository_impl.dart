import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../dao/company_dao.dart';
import '../models/company_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyDao _companyDao = CompanyDao();

  @override
  Future<List<Company>> getAllCompanies() async {
    final companyModels = await _companyDao.getAll();
    return companyModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Company?> getCompanyById(int id) async {
    final companyModel = await _companyDao.getById(id);
    return companyModel?.toEntity();
  }

  @override
  Future<List<Company>> searchCompanies(String query) async {
    final companyModels = await _companyDao.search(query);
    return companyModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> createCompany(Company company) async {
    final companyModel = CompanyModel.fromEntity(company);
    return await _companyDao.insert(companyModel);
  }

  @override
  Future<bool> updateCompany(Company company) async {
    final companyModel = CompanyModel.fromEntity(company);
    final result = await _companyDao.update(companyModel);
    return result > 0;
  }

  @override
  Future<bool> deleteCompany(int id) async {
    final result = await _companyDao.delete(id);
    return result > 0;
  }

  @override
  Future<bool> isNameUnique(String name, {int? excludeId}) async {
    return await _companyDao.isNameUnique(name, excludeId: excludeId);
  }
}