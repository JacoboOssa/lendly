enum RentalRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
  expired,
}

class RentalRequest {
  final String? id;
  final String productId;
  final String borrowerUserId;
  final DateTime startDate;
  final DateTime endDate;
  final RentalRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalRequest({
    this.id,
    required this.productId,
    required this.borrowerUserId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'borrower_user_id': borrowerUserId,
      'start_date': startDate.toIso8601String().split('T')[0], // Solo la fecha (YYYY-MM-DD)
      'end_date': endDate.toIso8601String().split('T')[0], // Solo la fecha (YYYY-MM-DD)
      'status': statusToDbString(status),
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'],
      productId: json['product_id'],
      borrowerUserId: json['borrower_user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: statusFromDbString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static String statusToDbString(RentalRequestStatus status) {
    switch (status) {
      case RentalRequestStatus.pending:
        return 'PENDING';
      case RentalRequestStatus.approved:
        return 'APPROVED';
      case RentalRequestStatus.rejected:
        return 'REJECTED';
      case RentalRequestStatus.cancelled:
        return 'CANCELLED';
      case RentalRequestStatus.expired:
        return 'EXPIRED';
    }
  }

  static RentalRequestStatus statusFromDbString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return RentalRequestStatus.pending;
      case 'APPROVED':
        return RentalRequestStatus.approved;
      case 'REJECTED':
        return RentalRequestStatus.rejected;
      case 'CANCELLED':
        return RentalRequestStatus.cancelled;
      case 'EXPIRED':
        return RentalRequestStatus.expired;
      default:
        return RentalRequestStatus.pending;
    }
  }
}

