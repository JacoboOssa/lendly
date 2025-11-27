class Conversation {
  final String id;
  final String profile1Id;
  final String profile2Id;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.profile1Id,
    required this.profile2Id,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile1_id': profile1Id,
      'profile2_id': profile2Id,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      profile1Id: json['profile1_id'] as String,
      profile2Id: json['profile2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool containsUser(String userId) {
    return profile1Id == userId || profile2Id == userId;
  }

  String getOtherUserId(String currentUserId) {
    return profile1Id == currentUserId ? profile2Id : profile1Id;
  }
}

