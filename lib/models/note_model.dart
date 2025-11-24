import 'package:hive/hive.dart';

part 'note_model.g.dart';

/// Модель заметки для хранения домашних заданий и важных событий
@HiveType(typeId: 2)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String subject; // Предмет

  @HiveField(3)
  String title; // Заголовок заметки

  @HiveField(4)
  String description; // Описание/содержание

  @HiveField(5)
  DateTime dueDate; // Срок выполнения

  @HiveField(6)
  bool isCompleted; // Выполнено или нет

  @HiveField(7)
  bool isImportant; // Важная заметка (для уведомлений)

  @HiveField(8)
  DateTime createdAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.isImportant = false,
    required this.createdAt,
  });

  NoteModel copyWith({
    String? id,
    String? userId,
    String? subject,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isImportant,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['userId'],
      subject: map['subject'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
      isImportant: map['isImportant'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}