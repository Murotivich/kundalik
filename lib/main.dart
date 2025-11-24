import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import 'models/user_model.dart';
import 'models/grade_model.dart';
import 'models/note_model.dart';
import 'models/attendance_model.dart';
import 'providers/auth_provider.dart';
import 'providers/diary_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive для локального хранения
  await Hive.initFlutter();

  // Регистрация адаптеров Hive
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(GradeModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());

  // Открытие боксов Hive
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<GradeModel>('grades');
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<AttendanceModel>('attendance');
  await Hive.openBox('settings');

  // Инициализация уведомлений
  tz.initializeTimeZones();
  // Инициализация данных локали для пакета intl (например, для 'ru')
  await initializeDateFormatting('ru');
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Электронный дневник',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}