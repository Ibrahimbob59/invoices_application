import 'dart:convert';
import '../../domain/entities/invoice.dart';

class InvoiceModel {
  final int? id;
  final int companyId;
  final String reference;
  final String date;
  final String? notes;
  final String? attachmentPathsJson;
  final String createdAt;
  final String updatedAt;

  const InvoiceModel({
    this.id,
    required this.companyId,
    required this.reference,
    required this.date,
    this.notes,
    this.attachmentPathsJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      companyId: map['company_id'] as int,
      reference: map['reference'] as String,
      date: map['date'] as String,
      notes: map['notes'] as String?,
      attachmentPathsJson: map['attachment_paths'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'reference': reference,
      'date': date,
      'notes': notes,
      'attachment_paths': attachmentPathsJson,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  List<String> get attachmentPaths {
    if (attachmentPathsJson == null || attachmentPathsJson!.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(attachmentPathsJson!);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Invoice toEntity() {
    return Invoice(
      id: id,
      companyId: companyId,
      reference: reference,
      date: DateTime.parse(date),
      notes: notes,
      attachmentPaths: attachmentPaths,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static InvoiceModel fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      companyId: invoice.companyId,
      reference: invoice.reference,
      date: invoice.date.toIso8601String().split('T')[0], // Store as date only
      notes: invoice.notes,
      attachmentPathsJson: invoice.attachmentPaths.isEmpty 
          ? null 
          : jsonEncode(invoice.attachmentPaths),
      createdAt: invoice.createdAt.toIso8601String(),
      updatedAt: invoice.updatedAt.toIso8601String(),
    );
  }
}