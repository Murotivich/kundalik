import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/grade_card.dart';
import '../../widgets/note_card.dart';
import 'add_grade_screen.dart';
import 'add_note_screen.dart';

/// Экран дневника с просмотром по предметам
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSubject;
  // фильтрация ведётся через `_selectedSubject` и вкладки

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final subjects = diaryProvider.getAllSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник'),
        actions: [
          // Фильтр по предметам
          if (subjects.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _selectedSubject = value == 'all' ? null : value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Все предметы'),
                ),
                ...subjects.map((subject) => PopupMenuItem(
                  value: subject,
                  child: Text(subject),
                )),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Оценки', icon: Icon(Icons.star)),
            Tab(text: 'Заметки', icon: Icon(Icons.assignment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGradesTab(diaryProvider),
          _buildNotesTab(diaryProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGradeScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNoteScreen(),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Оценка' : 'Заметка'),
      ),
    );
  }

  Widget _buildGradesTab(DiaryProvider provider) {
    var grades = _selectedSubject == null
        ? provider.grades
        : provider.getGradesBySubject(_selectedSubject!);

    if (grades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Оценок пока нет'),
            SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Группировка по предметам
    final groupedGrades = <String, List>{};
    for (var grade in grades) {
      groupedGrades.putIfAbsent(grade.subject, () => []).add(grade);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedGrades.length,
      itemBuilder: (context, index) {
        final subject = groupedGrades.keys.elementAt(index);
        final subjectGrades = groupedGrades[subject]!;
        final average = provider.getAverageGradeBySubject(subject);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                subject[0],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Средний балл: ${average.toStringAsFixed(2)}'),
            children: subjectGrades.map<Widget>((grade) {
              return GradeCard(grade: grade);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(DiaryProvider provider) {
    var notes = _selectedSubject == null
        ? provider.notes
        : provider.getNotesBySubject(_selectedSubject!);

    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Заметок пока нет'),
            SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(note: notes[index]);
      },
    );
  }
}