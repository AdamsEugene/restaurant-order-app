import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime dateCreated;
  final List<String>? photos;
  final String? orderId;
  final List<String> helpfulUserIds;
  final bool isVerifiedPurchase;
  
  const Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.dateCreated,
    this.photos,
    this.orderId,
    this.helpfulUserIds = const [],
    this.isVerifiedPurchase = false,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    userId,
    userName,
    userImageUrl,
    rating,
    comment,
    dateCreated,
    photos,
    orderId,
    helpfulUserIds,
    isVerifiedPurchase,
  ];
  
  // Create a copy of the review with updated fields
  Review copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userName,
    String? userImageUrl,
    double? rating,
    String? comment,
    DateTime? dateCreated,
    List<String>? photos,
    String? orderId,
    List<String>? helpfulUserIds,
    bool? isVerifiedPurchase,
  }) {
    return Review(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      dateCreated: dateCreated ?? this.dateCreated,
      photos: photos ?? this.photos,
      orderId: orderId ?? this.orderId,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }
  
  // Get the number of helpful votes
  int get helpfulCount => helpfulUserIds.length;
  
  // Check if a user has marked this review as helpful
  bool isHelpfulFor(String userId) => helpfulUserIds.contains(userId);
  
  // Add a helpful vote from a user
  Review markAsHelpful(String userId) {
    if (helpfulUserIds.contains(userId)) {
      return this;
    }
    
    return copyWith(
      helpfulUserIds: [...helpfulUserIds, userId],
    );
  }
  
  // Remove a helpful vote from a user
  Review removeHelpful(String userId) {
    if (!helpfulUserIds.contains(userId)) {
      return this;
    }
    
    return copyWith(
      helpfulUserIds: helpfulUserIds.where((id) => id != userId).toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'dateCreated': dateCreated.toIso8601String(),
      'photos': photos,
      'orderId': orderId,
      'helpfulUserIds': helpfulUserIds,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      restaurantId: json['restaurantId'],
      userId: json['userId'],
      userName: json['userName'],
      userImageUrl: json['userImageUrl'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      dateCreated: DateTime.parse(json['dateCreated']),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      orderId: json['orderId'],
      helpfulUserIds: json['helpfulUserIds'] != null 
          ? List<String>.from(json['helpfulUserIds']) 
          : const [],
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
    );
  }
} 