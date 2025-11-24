import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/grade_form.dart';

/// Экран выставления оценки от имени учителя для выбранного ученика
class AssignGradeScreen extends StatefulWidget {
  final UserModel student;
  const AssignGradeScreen({super.key, required this.student});

  @override
  State<AssignGradeScreen> createState() => _AssignGradeScreenState();
}

class _AssignGradeScreenState extends State<AssignGradeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выставить оценку — ${widget.student.name}')),
      body: GradeForm(
        userId: widget.student.id,
        onSave: (grade) async {
          final diaryProvider = context.read<DiaryProvider>();
          final nav = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          await diaryProvider.addGrade(grade);
          if (!mounted) return;
          nav.pop();
          messenger.showSnackBar(SnackBar(content: Text('Оценка добавлена для ${widget.student.name}')));
        },
      ),
    );
  }
}
