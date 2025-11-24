// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:electronic_diary/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Инициализируем Hive и открываем необходимые боксы для тестовой среды.
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('users');
    await Hive.openBox('grades');
    await Hive.openBox('notes');

    // Собираем приложение и ждём завершения анимаций/фреймов.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Ожидаем, что MaterialApp присутствует в дереве виджетов.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
