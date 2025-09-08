class Invoice {
  final int? id;
  final int companyId;
  final String reference;
  final DateTime date;
  final String? notes;
  final List<String> attachmentPaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    this.id,
    required this.companyId,
    required this.reference,
    required this.date,
    this.notes,
    this.attachmentPaths = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    int? id,
    int? companyId,
    String? reference,
    DateTime? date,
    String? notes,
    List<String>? attachmentPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      reference: reference ?? this.reference,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}