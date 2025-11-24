import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Модель пользователя для хранения данных о зарегистрированных пользователях
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  String name;

  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  String role; // 'student' or 'teacher'
  
  @HiveField(6)
  String? group; // optional group assignment

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.role = 'student',
    this.group,
  });

  // Копирование с изменениями
  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    DateTime? createdAt,
    String? role,
    String? group,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      group: group ?? this.group,
    );
  }

  // Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
      'group': group,
    };
  }

  // Создание из Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
      role: map['role'] ?? 'student',
      group: map['group'],
    );
  }
}