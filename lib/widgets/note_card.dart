import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/diary_provider.dart';
import '../screens/diary/add_note_screen.dart';

/// Виджет карточки заметки для отображения в списках
class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !note.isCompleted && note.dueDate.isBefore(DateTime.now());

    return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isOverdue
            ? Colors.red.shade50
            : note.isCompleted
            ? Colors.grey.shade100
            : null,
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNoteScreen(note: note),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Чекбокс
                  Checkbox(
                    value: note.isCompleted,
                    onChanged: (value) {
                      context.read<DiaryProvider>().toggleNoteCompletion(note.id);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Информация
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                    children: [
                    Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: note.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: note.isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                  if (note.isImportant)
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
              Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                note.subject,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.access_time,
              size: 14,
              color: isOverdue ? Colors.red : Colors.grey.shade600,
            ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yy HH:mm').format(note.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
                        const SizedBox(height: 4),
                        Text(
                          note.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: note.isCompleted
                                ? Colors.grey
                                : Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isOverdue) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.warning,
                                size: 14,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Просрочено',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}