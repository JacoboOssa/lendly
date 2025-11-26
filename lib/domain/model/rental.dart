enum RentalStatus {
  active,
  completed,
  cancelled,
}

class Rental {
  final String? id;
  final String rentalRequestId;
  final String productId;
  final String borrowerUserId;
  final String pickupLocation;
  final DateTime pickupAt;
  final RentalStatus status;
  final DateTime createdAt;

  Rental({
    this.id,
    required this.rentalRequestId,
    required this.productId,
    required this.borrowerUserId,
    required this.pickupLocation,
    required this.pickupAt,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rental_request_id': rentalRequestId,
      'product_id': productId,
      'borrower_user_id': borrowerUserId,
      'pickup_location': pickupLocation,
      'pickup_at': pickupAt.toIso8601String(),
      'status': _statusToDbString(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      rentalRequestId: json['rental_request_id'],
      productId: json['product_id'],
      borrowerUserId: json['borrower_user_id'],
      pickupLocation: json['pickup_location'],
      pickupAt: DateTime.parse(json['pickup_at']),
      status: _statusFromDbString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _statusToDbString(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return 'ACTIVE';
      case RentalStatus.completed:
        return 'COMPLETED';
      case RentalStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static RentalStatus _statusFromDbString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return RentalStatus.active;
      case 'COMPLETED':
        return RentalStatus.completed;
      case 'CANCELLED':
        return RentalStatus.cancelled;
      default:
        return RentalStatus.active;
    }
  }
}

