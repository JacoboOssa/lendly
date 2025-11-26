class Payment {
  final String? id;
  final String rentalId;
  final String ownerUserId;
  final String borrowerUserId;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyPrice;
  final double totalAmount;
  final bool paid;
  final int numberOfDays;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.rentalId,
    required this.ownerUserId,
    required this.borrowerUserId,
    required this.startDate,
    required this.endDate,
    required this.dailyPrice,
    required this.totalAmount,
    required this.paid,
    required this.numberOfDays,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rental_id': rentalId,
      'owner_user_id': ownerUserId,
      'borrower_user_id': borrowerUserId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'daily_price': dailyPrice,
      'total_amount': totalAmount,
      'paid': paid,
      'number_of_days': numberOfDays,
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      rentalId: json['rental_id'],
      ownerUserId: json['owner_user_id'],
      borrowerUserId: json['borrower_user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      dailyPrice: (json['daily_price'] is num)
          ? (json['daily_price'] as num).toDouble()
          : double.parse(json['daily_price'].toString()),
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : double.parse(json['total_amount'].toString()),
      paid: json['paid'] as bool,
      numberOfDays: json['number_of_days'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

