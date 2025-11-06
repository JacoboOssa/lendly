class Product {
  final String? id;
  final String ownerId;
  final String title;
  final String? description;
  final String? category;
  final int pricePerDayCents;
  final String? condition;
  final String? country;
  final String? city;
  final String? address;
  final String? pickupNotes;
  final bool active;
  final bool isAvailable;
  final String? photoUrl;
  final double? ratingAvg;
  final DateTime? createdAt;

  Product({
    this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.category,
    required this.pricePerDayCents,
    this.condition,
    this.country,
    this.city,
    this.address,
    this.pickupNotes,
    this.active = true,
    this.isAvailable = true,
    this.photoUrl,
    this.ratingAvg,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'owner_id': ownerId,
      'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      'price_per_day_cents': pricePerDayCents,
      if (condition != null) 'condition': condition,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (pickupNotes != null) 'pickup_notes': pickupNotes,
      'active': active,
      'is_available': isAvailable,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (ratingAvg != null) 'rating_avg': ratingAvg,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      pricePerDayCents: json['price_per_day_cents'],
      condition: json['condition'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
      pickupNotes: json['pickup_notes'],
      active: json['active'] ?? true,
      isAvailable: json['is_available'] ?? true,
      photoUrl: json['photo_url'],
      ratingAvg: json['rating_avg'] != null
          ? double.tryParse(json['rating_avg'].toString())
          : null,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
