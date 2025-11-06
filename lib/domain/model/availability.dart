class Availability {
  final String? id;
  final String itemId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isBlocked;
  final DateTime? createdAt;

  Availability({
    this.id,
    required this.itemId,
    required this.startDate,
    required this.endDate,
    this.isBlocked = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_blocked': isBlocked,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      itemId: json['item_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isBlocked: json['is_blocked'] ?? false,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
