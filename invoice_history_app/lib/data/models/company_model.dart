import '../../domain/entities/company.dart';

class CompanyModel {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const CompanyModel({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      taxId: map['tax_id'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'tax_id': taxId,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Company toEntity() {
    return Company(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      taxId: taxId,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static CompanyModel fromEntity(Company company) {
    return CompanyModel(
      id: company.id,
      name: company.name,
      phone: company.phone,
      email: company.email,
      address: company.address,
      taxId: company.taxId,
      notes: company.notes,
      createdAt: company.createdAt.toIso8601String(),
      updatedAt: company.updatedAt.toIso8601String(),
    );
  }
}