import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/grade_card.dart';
import '../../widgets/note_card.dart';

/// Экран календаря с просмотром событий по датам
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              });
            },
          ),
        ],
      ),
      body: Column(
          children: [
      Card(
      margin: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          final grades = diaryProvider.getGradesByDate(day);
          final notes = diaryProvider.getNotesByDate(day);
          return [...grades, ...notes];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha((0.5 * 255).round()),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
        ),
      ),
    ),
    const SizedBox(height: 8),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    _selectedDay != null
    ? DateFormat('d MMMM yyyy', 'ru').format(_selectedDay!)
        : 'Выберите дату',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    ),
    ),
    Row(
    children: [
    _buildLegendItem(
    context,
      Colors.amber,
      'Оценки',
    ),
      const SizedBox(width: 16),
      _buildLegendItem(
        context,
        Colors.blue,
        'Заметки',
      ),
    ],
    ),
    ],
    ),
    ),
            const Divider(height: 24),
            Expanded(
              child: _buildEventsList(diaryProvider),
            ),
          ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEventsList(DiaryProvider provider) {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Выберите дату в календаре'),
      );
    }

    final grades = provider.getGradesByDate(_selectedDay!);
    final notes = provider.getNotesByDate(_selectedDay!);

    if (grades.isEmpty && notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет событий на эту дату',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (grades.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Оценки (${grades.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...grades.map((grade) => GradeCard(grade: grade)),
          const SizedBox(height: 16),
        ],
        if (notes.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Заметки (${notes.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notes.map((note) => NoteCard(note: note)),
        ],
      ],
    );
  }
}