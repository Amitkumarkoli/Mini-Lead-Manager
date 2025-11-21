enum LeadStatus { newLead, contacted, converted, lost }

class Lead {
  final int? id;
  final String name;
  final String contact;
  final String? notes;
  final LeadStatus status;
  final DateTime createdAt;

  Lead({
    this.id,
    required this.name,
    required this.contact,
    this.notes,
    this.status = LeadStatus.newLead,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'notes': notes,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] as int?,
      name: map['name'] as String,
      contact: map['contact'] as String,
      notes: map['notes'] as String?,
      status: LeadStatus.values[map['status'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  Lead copyWith({
    int? id,
    String? name,
    String? contact,
    String? notes,
    LeadStatus? status,
    DateTime? createdAt,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}