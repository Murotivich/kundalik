import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grade_model.dart';
import '../screens/diary/add_grade_screen.dart';

/// Виджет карточки оценки для отображения в списках
class GradeCard extends StatelessWidget {
  final GradeModel grade;

  const GradeCard({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGradeScreen(grade: grade),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                // Оценка
                Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getGradeColor(grade.grade).withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getGradeColor(grade.grade),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    grade.grade.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(grade.grade),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            grade.gradeType,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (grade.comment != null && grade.comment!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              grade.comment!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
                  // Дата
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd.MM.yy').format(grade.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ),
    );
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
}