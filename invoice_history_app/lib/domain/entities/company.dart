class Company {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Company({
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

  Company copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? taxId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}