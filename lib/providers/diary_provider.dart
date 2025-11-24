import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/grade_model.dart';
import '../models/note_model.dart';

/// Provider для управления оценками и заметками
class DiaryProvider extends ChangeNotifier {
  List<GradeModel> _grades = [];
  List<NoteModel> _notes = [];
  String? _currentUserId;

  List<GradeModel> get grades => _grades;
  List<NoteModel> get notes => _notes;

  /// Установка текущего пользователя и загрузка данных
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    loadData();
  }

  /// Загрузка всех данных из Hive
  void loadData() {
    if (_currentUserId == null) return;

    final gradesBox = Hive.box<GradeModel>('grades');
    final notesBox = Hive.box<NoteModel>('notes');

    _grades = gradesBox.values
        .where((grade) => grade.userId == _currentUserId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _notes = notesBox.values
        .where((note) => note.userId == _currentUserId)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    notifyListeners();
  }

  // ========== ОЦЕНКИ ==========

  /// Добавление новой оценки
  Future<void> addGrade(GradeModel grade) async {
    final gradesBox = Hive.box<GradeModel>('grades');
    await gradesBox.put(grade.id, grade);
    loadData();
  }

  /// Обновление оценки
  Future<void> updateGrade(GradeModel grade) async {
    final gradesBox = Hive.box<GradeModel>('grades');
    await gradesBox.put(grade.id, grade);
    loadData();
  }

  /// Удаление оценки
  Future<void> deleteGrade(String gradeId) async {
    final gradesBox = Hive.box<GradeModel>('grades');
    await gradesBox.delete(gradeId);
    loadData();
  }

  /// Получение оценок по предмету
  List<GradeModel> getGradesBySubject(String subject) {
    return _grades.where((grade) => grade.subject == subject).toList();
  }

  /// Получение оценок за определенную дату
  List<GradeModel> getGradesByDate(DateTime date) {
    return _grades.where((grade) {
      return grade.date.year == date.year &&
          grade.date.month == date.month &&
          grade.date.day == date.day;
    }).toList();
  }

  /// Получение оценок за неделю
  List<GradeModel> getGradesForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _grades.where((grade) {
      return grade.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          grade.date.isBefore(weekEnd);
    }).toList();
  }

  /// Фильтрация оценок по типу
  List<GradeModel> filterGradesByType(String gradeType) {
    return _grades.where((grade) => grade.gradeType == gradeType).toList();
  }

  /// Получение среднего балла по предмету
  double getAverageGradeBySubject(String subject) {
    final subjectGrades = getGradesBySubject(subject);
    if (subjectGrades.isEmpty) return 0.0;

    final sum = subjectGrades.fold(0, (sum, grade) => sum + grade.grade);
    return sum / subjectGrades.length;
  }

  /// Получение всех уникальных предметов
  List<String> getAllSubjects() {
    final subjects = _grades.map((grade) => grade.subject).toSet().toList();
    subjects.sort();
    return subjects;
  }

  // ========== ЗАМЕТКИ ==========

  /// Добавление новой заметки
  Future<void> addNote(NoteModel note) async {
    final notesBox = Hive.box<NoteModel>('notes');
    await notesBox.put(note.id, note);
    loadData();
  }

  /// Обновление заметки
  Future<void> updateNote(NoteModel note) async {
    final notesBox = Hive.box<NoteModel>('notes');
    await notesBox.put(note.id, note);
    loadData();
  }

  /// Удаление заметки
  Future<void> deleteNote(String noteId) async {
    final notesBox = Hive.box<NoteModel>('notes');
    await notesBox.delete(noteId);
    loadData();
  }

  /// Переключение статуса выполнения заметки
  Future<void> toggleNoteCompletion(String noteId) async {
    final note = _notes.firstWhere((n) => n.id == noteId);
    final updatedNote = note.copyWith(isCompleted: !note.isCompleted);
    await updateNote(updatedNote);
  }

  /// Получение заметок по предмету
  List<NoteModel> getNotesBySubject(String subject) {
    return _notes.where((note) => note.subject == subject).toList();
  }

  /// Получение заметок за определенную дату
  List<NoteModel> getNotesByDate(DateTime date) {
    return _notes.where((note) {
      return note.dueDate.year == date.year &&
          note.dueDate.month == date.month &&
          note.dueDate.day == date.day;
    }).toList();
  }

  /// Получение невыполненных заметок
  List<NoteModel> getIncompleteNotes() {
    return _notes.where((note) => !note.isCompleted).toList();
  }

  /// Получение важных заметок
  List<NoteModel> getImportantNotes() {
    return _notes.where((note) => note.isImportant && !note.isCompleted).toList();
  }

  /// Получение просроченных заметок
  List<NoteModel> getOverdueNotes() {
    final now = DateTime.now();
    return _notes.where((note) {
      return !note.isCompleted && note.dueDate.isBefore(now);
    }).toList();
  }
}