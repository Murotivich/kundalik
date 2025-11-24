import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 3)
class AttendanceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final DateTime date; // дата урока

  @HiveField(3)
  final String lesson; // название предмета/урока

  @HiveField(4)
  final String status; // present/absent/late/other

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.lesson,
    required this.status,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    String? lesson,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      lesson: lesson ?? this.lesson,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
