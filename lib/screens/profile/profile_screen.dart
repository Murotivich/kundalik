import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/diary_provider.dart';

/// Экран профиля пользователя с настройками
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final diaryProvider = context.watch<DiaryProvider>();

    final user = authProvider.currentUser;
    if (user == null) return const SizedBox();

    // Статистика
    final totalGrades = diaryProvider.grades.length;
    final totalNotes = diaryProvider.notes.length;
    final completedNotes =
        diaryProvider.notes.where((n) => n.isCompleted).length;
    final averageGrade = totalGrades > 0
        ? diaryProvider.grades.fold(0, (sum, g) => sum + g.grade) / totalGrades
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
      // Профиль пользователя
      Card(
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
    ),
    const SizedBox(height: 16),

    // Статистика
    Card(
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Статистика',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    _buildStatRow(
    context,
    'Всего оценок',
    totalGrades.toString(),
    Icons.star,
    Colors.amber,
    ),
    const Divider(),
    _buildStatRow(
    context,
    'Средний балл',
    averageGrade.toStringAsFixed(2),
    Icons.trending_up,
    Colors.green,
    ),
    const Divider(),
    _buildStatRow(
    context,
    'Всего заметок',
    totalNotes.toString(),
    Icons.assignment,
    Colors.blue,
    ),
    const Divider(),
    _buildStatRow(
    context,
    'Выполнено заданий',
    '$completedNotes / $totalNotes',
    Icons.check_circle,
    Colors.purple,
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 16),

    // Настройки
    Card(
    child: Column(
    children: [
    ListTile(
    leading: const Icon(Icons.brightness_6),
    title: const Text('Тёмная тема'),
    trailing: Switch(
    value: themeProvider.isDarkMode,
    onChanged: (value) {
    themeProvider.toggleTheme();
    },
    ),
    ),
    const Divider(height: 1),
    ListTile(
    leading: const Icon(Icons.notifications),
    title: const Text('Уведомления'),
    subtitle: const Text('Настройка напоминаний'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    title: const Text('Уведомления'),
    content: const Text(
    'Уведомления активны для важных заданий. '
    'Вы получите напоминание за 1 час до срока.',
    ),
    actions: [
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('OK'),
    ),
    ],
    ),
    );
    },
    ),
    const Divider(height: 1),
    ListTile(
    leading: const Icon(Icons.edit),
    title: const Text('Редактировать профиль'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
    _showEditProfileDialog(context, authProvider);
    },
    ),
    ],
    ),
    ),
    const SizedBox(height: 16),

    // О приложении
    Card(
    child: ListTile(
    leading: const Icon(Icons.info),
    title: const Text('О приложении'),
    subtitle: const Text('Электронный дневник v1.0.0'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
    showAboutDialog(
    context: context,
    applicationName: 'Электронный дневник',
    applicationVersion: '1.0.0',
    applicationIcon: const Icon(Icons.school, size: 48),
    children: [
    const Text(
    'Приложение для учета оценок и домашних заданий. '
    'Разработано на Flutter 3+ с использованием Material Design.',
    ),
    ],
    );
    },
    ),
    ),
    const SizedBox(height: 24),

    // Кнопка выхода
    OutlinedButton.icon(
    onPressed: () async {
    final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
    title: const Text('Выход из аккаунта'),
    content: const Text('Вы уверены, что хотите выйти?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Отмена'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Выйти'),
      ),
    ],
    ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.logout();
    }
    },
      icon: const Icon(Icons.logout),
      label: const Text('Выйти из аккаунта'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
          ],
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(
      text: authProvider.currentUser?.name ?? '',
    );
    final emailController = TextEditingController(
      text: authProvider.currentUser?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final error = await authProvider.updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error ?? 'Профиль обновлен',
                    ),
                    backgroundColor: error != null ? Colors.red : Colors.green,
                  ),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}