import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../dao/invoice_dao.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceDao _invoiceDao = InvoiceDao();

  @override
  Future<List<Map<String, dynamic>>> getAllInvoicesWithCompany() async {
    return await _invoiceDao.getInvoicesWithCompany();
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoicesByCompany(int companyId) async {
    return await _invoiceDao.getInvoicesByCompany(companyId);
  }

  @override
  Future<Invoice?> getInvoiceById(int id) async {
    final invoiceModel = await _invoiceDao.getById(id);
    return invoiceModel?.toEntity();
  }

  @override
  Future<List<Map<String, dynamic>>> searchInvoices(String query) async {
    return await _invoiceDao.searchInvoices(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoicesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    return await _invoiceDao.getInvoicesByDateRange(startDate, endDate);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoicesByDate(String date) async {
    return await _invoiceDao.getInvoicesByDate(date);
  }

  @override
  Future<int> createInvoice(Invoice invoice) async {
    final invoiceModel = InvoiceModel.fromEntity(invoice);
    return await _invoiceDao.insert(invoiceModel);
  }

  @override
  Future<bool> updateInvoice(Invoice invoice) async {
    final invoiceModel = InvoiceModel.fromEntity(invoice);
    final result = await _invoiceDao.update(invoiceModel);
    return result > 0;
  }

  @override
  Future<bool> deleteInvoice(int id) async {
    final result = await _invoiceDao.delete(id);
    return result > 0;
  }

  @override
  Future<bool> isReferenceUniqueForCompany(
    String reference, 
    int companyId, 
    {int? excludeId}
  ) async {
    return await _invoiceDao.isReferenceUniqueForCompany(
      reference, 
      companyId, 
      excludeId: excludeId
    );
  }
}