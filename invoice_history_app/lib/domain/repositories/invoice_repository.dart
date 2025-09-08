import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Map<String, dynamic>>> getAllInvoicesWithCompany();
  Future<List<Map<String, dynamic>>> getInvoicesByCompany(int companyId);
  Future<Invoice?> getInvoiceById(int id);
  Future<List<Map<String, dynamic>>> searchInvoices(String query);
  Future<List<Map<String, dynamic>>> getInvoicesByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Map<String, dynamic>>> getInvoicesByDate(String date);
  Future<int> createInvoice(Invoice invoice);
  Future<bool> updateInvoice(Invoice invoice);
  Future<bool> deleteInvoice(int id);
  Future<bool> isReferenceUniqueForCompany(String reference, int companyId, {int? excludeId});
}