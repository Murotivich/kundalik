import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../models/note_model.dart';
import '../../services/notification_service.dart';

/// Экран добавления/редактирования заметки
class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isImportant = false;

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
    if (widget.note != null) {
      _subjectController.text = widget.note!.subject;
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _selectedDate = widget.note!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.note!.dueDate);
      _isImportant = widget.note!.isImportant;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final diaryProvider = context.read<DiaryProvider>();

    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final noteId = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final note = NoteModel(
      id: noteId,
      userId: authProvider.currentUser!.id,
      subject: _subjectController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDate,
      isCompleted: widget.note?.isCompleted ?? false,
      isImportant: _isImportant,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
    );

    if (widget.note == null) {
      await diaryProvider.addNote(note);
    } else {
      await diaryProvider.updateNote(note);
    }

    // Установка напоминания для важных заметок
    if (_isImportant && dueDate.isAfter(DateTime.now())) {
      final reminderTime = dueDate.subtract(const Duration(hours: 1));
      if (reminderTime.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          id: noteId.hashCode,
          title: '📚 Напоминание: ${note.subject}',
          body: note.title,
          scheduledDate: reminderTime,
          payload: noteId,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.note == null
            ? 'Заметка добавлена'
            : 'Заметка обновлена'),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Новая заметка' : 'Редактировать'),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                  final diaryProvider = context.read<DiaryProvider>();
                  final notificationService = NotificationService();

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                    title: const Text('Удалить заметку?'),
                    content: const Text('Это действие нельзя отменить'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (!mounted) return;
                  await diaryProvider.deleteNote(widget.note!.id);
                  await notificationService.cancelNotification(widget.note!.id.hashCode);
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
        // Предмет
        Autocomplete<String>(
        initialValue: TextEditingValue(text: _subjectController.text),
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return _subjects;
          }
          return _subjects.where((subject) => subject
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (selection) {
          _subjectController.text = selection;
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          _subjectController.text = controller.text;
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Предмет',
              prefixIcon: Icon(Icons.book),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите предмет';
              }
              return null;
            },
          );
        },
      ),
      const SizedBox(height: 16),

      // Заголовок
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Заголовок',
          prefixIcon: Icon(Icons.title),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Введите заголовок';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      // Описание
      TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Описание',
          prefixIcon: Icon(Icons.description),
          alignLabelWithHint: true,
        ),
        maxLines: 5,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Введите описание';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
              // Дата и время
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Дата'),
                      subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: const Icon(Icons.access_time),
                      title: const Text('Время'),
                      subtitle: Text(_selectedTime.format(context)),
                      onTap: _selectTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Важная заметка
              SwitchListTile(
                title: const Text('Важное задание'),
                subtitle: const Text('Будет отправлено напоминание за час'),
                value: _isImportant,
                onChanged: (value) {
                  setState(() => _isImportant = value);
                },
                secondary: Icon(
                  _isImportant ? Icons.star : Icons.star_border,
                  color: _isImportant ? Colors.amber : null,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка сохранения
              ElevatedButton(
                onPressed: _saveNote,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Сохранить'),
                ),
              ),
            ],
        ),
      ),
    );
  }
}