import 'package:hive/hive.dart';

part 'grade_model.g.dart';

/// Модель оценки с информацией о предмете, дате и типе
@HiveType(typeId: 1)
class GradeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String subject; // Предмет (Математика, Физика и т.д.)

  @HiveField(3)
  int grade; // Оценка (2-5)

  @HiveField(4)
  String gradeType; // Тип оценки (Контрольная, Самостоятельная, Домашнее задание и т.д.)

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? comment; // Комментарий учителя

  @HiveField(7)
  DateTime createdAt;

  GradeModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.grade,
    required this.gradeType,
    required this.date,
    this.comment,
    required this.createdAt,
  });

  GradeModel copyWith({
    String? id,
    String? userId,
    String? subject,
    int? grade,
    String? gradeType,
    DateTime? date,
    String? comment,
    DateTime? createdAt,
  }) {
    return GradeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      gradeType: gradeType ?? this.gradeType,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'grade': grade,
      'gradeType': gradeType,
      'date': date.toIso8601String(),
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GradeModel.fromMap(Map<String, dynamic> map) {
    return GradeModel(
      id: map['id'],
      userId: map['userId'],
      subject: map['subject'],
      grade: map['grade'],
      gradeType: map['gradeType'],
      date: DateTime.parse(map['date']),
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}