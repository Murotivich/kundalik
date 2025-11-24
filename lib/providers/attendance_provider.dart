import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _records = [];

  List<AttendanceModel> get records => _records;

  /// Загрузить записи для конкретного ученика
  List<AttendanceModel> getByStudent(String studentId) {
    final box = Hive.box<AttendanceModel>('attendance');
    final items = box.values.where((a) => a.studentId == studentId).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Загрузка всех записей в память (если нужно)
  void loadAll() {
    final box = Hive.box<AttendanceModel>('attendance');
    _records = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addAttendance(AttendanceModel record) async {
    final box = Hive.box<AttendanceModel>('attendance');
    await box.put(record.id, record);
    loadAll();
  }

  Future<void> updateAttendance(AttendanceModel record) async {
    final box = Hive.box<AttendanceModel>('attendance');
    await box.put(record.id, record);
    loadAll();
  }

  Future<void> deleteAttendance(String id) async {
    final box = Hive.box<AttendanceModel>('attendance');
    await box.delete(id);
    loadAll();
  }
}
