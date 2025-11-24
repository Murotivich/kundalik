import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../models/grade_model.dart';
import '../../widgets/grade_form.dart';

/// Экран добавления/редактирования оценки
class AddGradeScreen extends StatefulWidget {
  final GradeModel? grade;

  const AddGradeScreen({super.key, this.grade});

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final role = authProvider.currentUser?.role ?? 'student';
      if (role != 'teacher') {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context);
        messenger.showSnackBar(const SnackBar(content: Text('Только учитель может добавлять оценки')));
        nav.pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade == null ? 'Новая оценка' : 'Редактировать'),
        actions: [
          if (widget.grade != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final diaryProvider = context.read<DiaryProvider>();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить оценку?'),
                    content: const Text('Это действие нельзя отменить'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                    ],
                  ),
                );

                if (confirm == true) {
                    if (!mounted) return;
                    final nav = Navigator.of(context);
                    await diaryProvider.deleteGrade(widget.grade!.id);
                    if (!mounted) return;
                    nav.pop();
                }
              },
            ),
        ],
      ),
      body: GradeForm(
        userId: Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
        initial: widget.grade,
        onSave: (grade) async {
          final diaryProvider = context.read<DiaryProvider>();
          final nav = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          if (widget.grade == null) {
            await diaryProvider.addGrade(grade);
          } else {
            await diaryProvider.updateGrade(grade);
          }
          if (!mounted) return;
          nav.pop();
          messenger.showSnackBar(SnackBar(content: Text(widget.grade == null ? 'Оценка добавлена' : 'Оценка обновлена')));
        },
      ),
    );
  }

  // UI and form are provided by GradeForm widget
}