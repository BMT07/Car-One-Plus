class Review {
  final int? id;
  final int? userId;
  final String? userLname;
  final String? userFname;
  final int? vehicleId;
  final String? vehicleName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.userId,
    this.userLname,
    this.userFname,
    required this.vehicleId,
    this.vehicleName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      userLname: json['user_lname'],
      userFname: json['user_fname'],
      vehicleId: json['vehicle_id'],
      vehicleName: json['vehicle_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_lname': userLname,
      'user_fname': userFname,
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}