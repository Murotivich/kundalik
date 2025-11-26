import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../diary/diary_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../teacher/teacher_dashboard.dart';
import '../../widgets/grade_card.dart';
import '../../widgets/note_card.dart';

/// Главный экран приложения с обзором недели
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // dynamic screens are built in `build` depending on user role

  @override
  void initState() {
    super.initState();
    // Загрузка данных для текущего пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final diaryProvider = context.read<DiaryProvider>();
      if (authProvider.currentUser != null) {
        diaryProvider.setCurrentUser(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.currentUser?.role ?? 'student';
    // Build stack children dynamically depending on role
    final children = <Widget>[];
    if (role == 'teacher') {
      children.add(const TeacherDashboard());
    } else {
      children.add(const HomeContent());
    }
    children.addAll(const [
      DiaryScreen(),
      CalendarScreen(),
      ProfileScreen(),
    ]);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: children,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Дневник',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Календарь',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

/// Содержимое главной страницы
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final diaryProvider = context.watch<DiaryProvider>();

    // Получение оценок и заметок за текущую неделю
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekGrades = diaryProvider.getGradesForWeek(weekStart);
    final incompleteNotes = diaryProvider.getIncompleteNotes();
    final overdueNotes = diaryProvider.getOverdueNotes();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Главная'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Показать уведомления
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Уведомления в разработке'),
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              diaryProvider.loadData();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
    // Приветствие
                Text(
                'Здравствуй, ${authProvider.currentUser?.name ?? "Ученик"}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM', 'ru').format(now),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Статистика недели
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статистика недели',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.star,
                              label: 'Оценки',
                              value: weekGrades.length.toString(),
                              color: Colors.amber,
                            ),
                            _StatItem(
                              icon: Icons.assignment,
                              label: 'Задания',
                              value: incompleteNotes.length.toString(),
                              color: Colors.blue,
                            ),
                            _StatItem(
                              icon: Icons.warning,
                              label: 'Просрочено',
                              value: overdueNotes.length.toString(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Последние оценки
                Text(
                  'Последние оценки',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                weekGrades.isEmpty
                    ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Оценок за эту неделю пока нет'),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weekGrades.length > 5 ? 5 : weekGrades.length,
                  itemBuilder: (context, index) {
                    return GradeCard(grade: weekGrades[index]);
                  },
                ),
                const SizedBox(height: 24),

                // Активные задания
                Text(
                  'Активные задания',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                incompleteNotes.isEmpty
                    ? const Card(
                    child: Padding(padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Все задания выполнены! 🎉'),
                      ),
                    ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incompleteNotes.length > 5 ? 5 : incompleteNotes.length,
                  itemBuilder: (context, index) {
                    return NoteCard(note: incompleteNotes[index]);
                  },
                ),
                          ],
                      ),
                    ),
                  );
              },
            ),
        ),
    );
  }
}

/// Виджет для отображения статистики
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}