import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId? id;
  final String email;
  final String password; // Should be hashed in a real app
  final String? name;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as ObjectId,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  UserModel copyWith({
    ObjectId? id,
    String? email,
    String? password,
    String? name,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
