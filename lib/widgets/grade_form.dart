import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grade_model.dart';

/// Переиспользуемая форма для ввода/редактирования оценки.
/// - `userId` — id пользователя, для которого сохраняется оценка
/// - `initial` — начальные данные (если редактирование)
/// - `onSave` — callback, вызываемый с готовой моделью оценки
class GradeForm extends StatefulWidget {
  final String userId;
  final GradeModel? initial;
  final Future<void> Function(GradeModel) onSave;

  const GradeForm({super.key, required this.userId, this.initial, required this.onSave});

  @override
  State<GradeForm> createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _commentController;

  int _selectedGrade = 5;
  String _selectedGradeType = 'Домашнее задание';
  DateTime _selectedDate = DateTime.now();

  final List<String> _gradeTypes = [
    'Домашнее задание',
    'Контрольная работа',
    'Самостоятельная работа',
    'Тест',
    'Устный ответ',
    'Лабораторная работа',
    'Проект',
  ];

  final List<String> _subjects = [
    'Математика',
    'Русский язык',
    'Литература',
    'Английский язык',
    'История',
    'Обществознание',
    'География',
    'Биология',
    'Физика',
    'Химия',
    'Информатика',
    'Физкультура',
    'ОБЖ',
  ];

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.initial?.subject ?? '');
    _commentController = TextEditingController(text: widget.initial?.comment ?? '');
    _selectedGrade = widget.initial?.grade ?? 5;
    _selectedGradeType = widget.initial?.gradeType ?? _selectedGradeType;
    _selectedDate = widget.initial?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final grade = GradeModel(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.userId,
      subject: _subjectController.text.trim(),
      grade: _selectedGrade,
      gradeType: _selectedGradeType,
      date: _selectedDate,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
    );

    await widget.onSave(grade);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _subjectController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return _subjects;
              return _subjects.where((subject) => subject.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (selection) => _subjectController.text = selection,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              _subjectController.text = controller.text;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Предмет', prefixIcon: Icon(Icons.book)),
                validator: (value) => (value == null || value.isEmpty) ? 'Введите предмет' : null,
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Оценка', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [2, 3, 4, 5].map((grade) {
                      return ChoiceChip(
                        label: Text(grade.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        selected: _selectedGrade == grade,
                        onSelected: (selected) => setState(() => _selectedGrade = grade),
                        selectedColor: _getGradeColor(grade),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGradeType,
            decoration: const InputDecoration(labelText: 'Тип оценки', prefixIcon: Icon(Icons.category)),
            items: _gradeTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (v) => setState(() => _selectedGradeType = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Дата'),
            subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Комментарий (необязательно)', prefixIcon: Icon(Icons.comment)),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _onSavePressed, child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Сохранить'))),
        ],
      ),
    );
  }
}
