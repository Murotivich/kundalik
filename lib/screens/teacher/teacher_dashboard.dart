import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../../src/download_helper_stub.dart'
  if (dart.library.html) '../../src/download_helper_web.dart'
  if (dart.library.io) '../../src/download_helper_io.dart';
import '../../models/user_model.dart';
import '../teacher/student_detail.dart';
import '../teacher/assign_grade_screen.dart';

/// Простая панель учителя: группы (пока заглушка) и список учеников
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String _selectedGroup = 'Все учащиеся';
  List<String> _groups = ['Все учащиеся', 'Класс 10А', 'Класс 9Б'];
  List<UserModel> _students = [];
  List<UserModel> _teachers = [];
  String _viewMode = 'students'; // 'students' or 'teachers'

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadStudents();
    _loadTeachers();
  }

  void _loadGroups() {
    final settings = Hive.box('settings');
    final stored = settings.get('groups');
    if (stored is List) {
      try {
        final items = List<String>.from(stored);
        // ensure default exists
        if (!items.contains('Все учащиеся')) items.insert(0, 'Все учащиеся');
        setState(() => _groups = items);
        if (!_groups.contains(_selectedGroup)) _selectedGroup = _groups.first;
        return;
      } catch (_) {
        // ignore malformed data
      }
    }
    // if no stored value, keep default _groups
    if (!settings.containsKey('groups')) {
      settings.put('groups', _groups);
    }
  }

  Future<void> _addGroupDialog() async {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final res = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить группу'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Название группы'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Добавить')),
          ],
        );
      },
    );

    if (res != null && res.isNotEmpty) {
      final settings = Hive.box('settings');
      final current = (settings.get('groups') as List?)?.cast<String>() ?? _groups;
      if (!current.contains(res)) {
        current.add(res);
        await settings.put('groups', current);
        if (!mounted) return;
        setState(() => _groups = List<String>.from(current));
        setState(() => _selectedGroup = res);
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Группа уже существует')));
      }
    }
  }

  Future<void> _manageGroupsDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    final settings = Hive.box('settings');
    final current = (settings.get('groups') as List?)?.cast<String>() ?? _groups;
    final parentContext = context;
    final nav = Navigator.of(parentContext);

    await showModalBottomSheet<void>(
      context: parentContext,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              ListTile(
                title: const Text('Управление группами'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    nav.pop();
                    await _addGroupDialog();
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: current.length,
                  itemBuilder: (context, index) {
                    final g = current[index];
                    return ListTile(
                      title: Text(g),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final controller = TextEditingController(text: g);
                              final newName = await showDialog<String?>(
                                context: parentContext,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Переименовать группу'),
                                    content: TextField(controller: controller),
                                    actions: [
                                      TextButton(onPressed: () => nav.pop(), child: const Text('Отмена')),
                                      ElevatedButton(onPressed: () => nav.pop(controller.text.trim()), child: const Text('Сохранить')),
                                    ],
                                  );
                                },
                              );
                                if (newName != null && newName.isNotEmpty && newName != g) {
                                final updated = List<String>.from(current);
                                updated[index] = newName;
                                await settings.put('groups', updated);
                                if (!mounted) return;
                                setState(() => _groups = updated);
                                messenger.showSnackBar(const SnackBar(content: Text('Группа переименована')));
                                nav.pop();
                                await _manageGroupsDialog();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: g == 'Все учащиеся'
                                ? null
                                : () async {
                                    final confirm = await showDialog<bool?>(
                                      context: parentContext,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Удалить группу'),
                                          content: Text('Удалить группу "$g"? Это действие нельзя отменить.'),
                                          actions: [
                                            TextButton(onPressed: () => nav.pop(false), child: const Text('Отмена')),
                                            ElevatedButton(onPressed: () => nav.pop(true), child: const Text('Удалить')),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      final updated = List<String>.from(current)..removeAt(index);
                                      await settings.put('groups', updated);
                                      if (!mounted) return;
                                      setState(() => _groups = updated);
                                      if (_selectedGroup == g) setState(() => _selectedGroup = _groups.first);
                                      messenger.showSnackBar(const SnackBar(content: Text('Группа удалена')));
                                      nav.pop();
                                      await _manageGroupsDialog();
                                    }
                                  },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadStudents() {
    final usersBox = Hive.box<UserModel>('users');
    var students = usersBox.values.where((u) => u.role == 'student').toList();
    if (_selectedGroup != 'Все учащиеся') {
      students = students.where((u) => (u.group ?? '') == _selectedGroup).toList();
    }
    students.sort((a, b) => a.name.compareTo(b.name));
    setState(() => _students = students);
  }

  void _loadTeachers() {
    final usersBox = Hive.box<UserModel>('users');
    final teachers = usersBox.values.where((u) => u.role == 'teacher').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    setState(() => _teachers = teachers);
  }

  Future<void> _addStudentDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? chosenGroup = _selectedGroup == 'Все учащиеся' ? null : _selectedGroup;

    final res = await showDialog<bool?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Добавить ученика'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ФИО')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Пароль')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: chosenGroup ?? 'Без группы',
                  items: ([ 'Без группы' ] + _groups.where((g) => g != 'Все учащиеся').toList())
                      .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) {
                    if (v == 'Без группы') {
                      chosenGroup = null;
                    } else {
                      chosenGroup = v;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Группа'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Создать')),
          ],
        );
      },
    );

    if (res == true) {
      final name = nameCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final pass = passCtrl.text.trim();
      if (name.isEmpty || email.isEmpty || pass.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Пожалуйста, заполните все поля')));
        return;
      }

      final usersBox = Hive.box<UserModel>('users');
      // check duplicate
      final exists = usersBox.values.any((u) => u.email == email);
      if (exists) {
        messenger.showSnackBar(const SnackBar(content: Text('Пользователь с таким email уже существует')));
        return;
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        id: id,
        email: email,
        password: pass,
        name: name,
        createdAt: DateTime.now(),
        role: 'student',
        group: chosenGroup,
      );

      await usersBox.put(id, user);
      if (!mounted) return;
      _loadStudents();
      messenger.showSnackBar(const SnackBar(content: Text('Ученик создан')));
      // Показать запись ученика в виде таблицы
      await _showStudentTable(user);
    }
  }

  Future<void> _showStudentTable(UserModel user) async {
    final nav = Navigator.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Данные ученика'),
          content: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Поле')),
                DataColumn(label: Text('Значение')),
              ],
              rows: [
                DataRow(cells: [DataCell(Text('ID')), DataCell(Text(user.id))]),
                DataRow(cells: [DataCell(Text('ФИО')), DataCell(Text(user.name))]),
                DataRow(cells: [DataCell(Text('Email')), DataCell(Text(user.email))]),
                DataRow(cells: [DataCell(Text('Группа')), DataCell(Text(user.group ?? 'Без группы'))]),
                DataRow(cells: [DataCell(Text('Роль')), DataCell(Text(user.role))]),
                DataRow(cells: [DataCell(Text('Создан')), DataCell(Text(user.createdAt.toLocal().toString()))]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => nav.pop(), child: const Text('Закрыть')),
            TextButton(
              onPressed: () async {
                // build CSV
                final csvRows = [
                  ['Поле', 'Значение'],
                  ['ID', user.id],
                  ['ФИО', user.name],
                  ['Email', user.email],
                  ['Группа', user.group ?? 'Без группы'],
                  ['Роль', user.role],
                  ['Создан', user.createdAt.toLocal().toString()],
                ];
                String escape(String v) {
                  if (v.contains(',') || v.contains('"') || v.contains('\n')) {
                    return '"' + v.replaceAll('"', '""') + '"';
                  }
                  return v;
                }

                final csv = csvRows.map((r) => r.map((c) => escape(c)).join(',')).join('\n');
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await downloadCsv('student_${user.id}.csv', csv);
                  messenger.showSnackBar(const SnackBar(content: Text('CSV экспортирован')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Ошибка экспорта CSV: $e')));
                }
              },
              child: const Text('Скачать CSV'),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await printPage();
                } catch (e) {
                  messenger.showSnackBar(const SnackBar(content: Text('Печать не поддерживается на этой платформе')));
                }
              },
              child: const Text('Печать (сохранить как PDF)'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель учителя'),
        actions: [
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () async {
                // Показать меню управления группами
                await showModalBottomSheet<void>(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Добавить группу'),
                          onTap: () {
                            Navigator.pop(context);
                            _addGroupDialog();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.manage_accounts),
                          title: const Text('Управление группами'),
                          onTap: () {
                            Navigator.pop(context);
                            _manageGroupsDialog();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _addStudentDialog,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ToggleButtons(
                    isSelected: [_viewMode == 'students', _viewMode == 'teachers'],
                    onPressed: (i) {
                      setState(() {
                        _viewMode = i == 0 ? 'students' : 'teachers';
                        if (_viewMode == 'students') {
                          _loadStudents();
                        } else {
                          _loadTeachers();
                        }
                      });
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Ученики')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Учителя'))
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Text('Группа:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedGroup,
                    items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedGroup = v);
                      _loadStudents();
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _viewMode == 'students' ? 'Ученики: ${_students.length}' : 'Учителя: ${_teachers.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _viewMode == 'students' ? _students.length : _teachers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final s = _viewMode == 'students' ? _students[index] : _teachers[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(s.name.isNotEmpty ? s.name[0] : '?')),
                  title: Text(s.name),
                  subtitle: Text(s.email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (_viewMode == 'students') {
                        if (action == 'details') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StudentDetail(student: s)),
                          );
                          _loadStudents();
                        } else if (action == 'grade') {
                          // Open assign grade screen for this student
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AssignGradeScreen(student: s)),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Оценка добавлена')));
                          _loadStudents();
                        } else if (action == 'assign') {
                          // choose group
                          final messenger = ScaffoldMessenger.of(context);
                          final options = <String>['Без группы'] + _groups.where((g) => g != 'Все учащиеся').toList();
                          final chosen = await showDialog<String?>(
                            context: context,
                            builder: (ctx) {
                              return SimpleDialog(
                                title: const Text('Назначить группу'),
                                children: options.map((g) {
                                  return SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, g),
                                    child: Text(g),
                                  );
                                }).toList(),
                              );
                            },
                          );
                          if (chosen != null) {
                            final usersBox = Hive.box<UserModel>('users');
                            final updated = s.copyWith(group: chosen == 'Без группы' ? null : chosen);
                            await usersBox.put(s.id, updated);
                            if (!mounted) return;
                            _loadStudents();
                            messenger.showSnackBar(SnackBar(content: Text('Группа ученика обновлена: $chosen')));
                          }
                        }
                      } else {
                        // teachers actions
                        if (action == 'details') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StudentDetail(student: s)),
                          );
                          _loadTeachers();
                        } else if (action == 'login') {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final err = await auth.loginById(s.id);
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                            return;
                          }
                          // Navigate to home as the logged-in teacher
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => _viewMode == 'students'
                        ? [
                            const PopupMenuItem(value: 'details', child: Text('Детали')),
                            const PopupMenuItem(value: 'grade', child: Text('Выставить оценку')),
                            const PopupMenuItem(value: 'assign', child: Text('Назначить группу')),
                          ]
                        : [
                            const PopupMenuItem(value: 'details', child: Text('Детали')),
                            const PopupMenuItem(value: 'login', child: Text('Войти как')),
                          ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentDetail(student: s)),
                    );
                    if (_viewMode == 'students') _loadStudents(); else _loadTeachers();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
