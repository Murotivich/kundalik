import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../models/user_model.dart';
import '../../models/grade_model.dart';

class StudentDetail extends StatefulWidget {
  final UserModel student;
  const StudentDetail({super.key, required this.student});

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  List<GradeModel> _grades = [];
  List<AttendanceModel> _attendance = [];

  final TextEditingController _lessonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'present';

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  void _loadGrades() {
    final gradesBox = Hive.box<GradeModel>('grades');
    final grades = gradesBox.values.where((g) => g.userId == widget.student.id).toList();
    grades.sort((a, b) => b.date.compareTo(a.date));
    setState(() => _grades = grades);
    _loadAttendance();
  }

  void _loadAttendance() {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final items = provider.getByStudent(widget.student.id);
    setState(() => _attendance = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.student.email}'),
            const SizedBox(height: 8),
            Text('Зарегистрирован: ${widget.student.createdAt.toLocal().toString().split(" ").first}'),
            const SizedBox(height: 16),
            const Text('Оценки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _grades.isEmpty
                  ? const Center(child: Text('Оценок пока нет'))
                  : Expanded(
                      child: ListView.separated(
                        itemCount: _grades.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final g = _grades[index];
                          return ListTile(
                            title: Text('${g.subject} — ${g.grade}'),
                            subtitle: Text('${g.gradeType} • ${g.date.toLocal().toString().split(" ").first}'),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Посещаемость', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Форма добавления посещаемости
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Дата: ${_selectedDate.toLocal().toString().split(" ").first}'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (d != null) setState(() => _selectedDate = d);
                                },
                                child: const Text('Выбрать дату'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _lessonController,
                            decoration: const InputDecoration(labelText: 'Урок / предмет'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Статус: '),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedStatus,
                                items: const [
                                  DropdownMenuItem(value: 'present', child: Text('Присутствовал')),
                                  DropdownMenuItem(value: 'absent', child: Text('Отсутствовал')),
                                  DropdownMenuItem(value: 'late', child: Text('Опоздал')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => _selectedStatus = v);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(labelText: 'Комментарий (необязательно)'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final provider = Provider.of<AttendanceProvider>(context, listen: false);
                                  final id = DateTime.now().microsecondsSinceEpoch.toString();
                                  final record = AttendanceModel(
                                    id: id,
                                    studentId: widget.student.id,
                                    date: _selectedDate,
                                    lesson: _lessonController.text.trim(),
                                    status: _selectedStatus,
                                    notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                                  );
                                  await provider.addAttendance(record);
                                  _lessonController.clear();
                                  _notesController.clear();
                                  _selectedDate = DateTime.now();
                                  _selectedStatus = 'present';
                                  _loadAttendance();
                                },
                                child: const Text('Сохранить'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  _lessonController.clear();
                                  _notesController.clear();
                                },
                                child: const Text('Очистить'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Список посещаемости
                  Expanded(
                    child: _attendance.isEmpty
                        ? const Center(child: Text('Записей посещаемости пока нет'))
                        : ListView.separated(
                            itemCount: _attendance.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final a = _attendance[index];
                              return ListTile(
                                title: Text('${a.lesson} • ${a.date.toLocal().toString().split(' ').first}'),
                                subtitle: Text('${a.status}${a.notes != null ? ' • ${a.notes}' : ''}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final provider = Provider.of<AttendanceProvider>(context, listen: false);
                                    await provider.deleteAttendance(a.id);
                                    _loadAttendance();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
