import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

/// Provider для управления аутентификацией пользователей
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// Проверка статуса аутентификации при запуске приложения
  Future<void> _checkAuthStatus() async {
    final settingsBox = Hive.box('settings');
    final currentUserId = settingsBox.get('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<UserModel>('users');
      _currentUser = usersBox.get(currentUserId);
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    }
  }

  /// Регистрация нового пользователя
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    try {
      final usersBox = Hive.box<UserModel>('users');

      // Проверка на существующего пользователя
      final existingUser = usersBox.values.firstWhere(
            (user) => user.email == email,
        orElse: () => UserModel(
          id: '',
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existingUser.id.isNotEmpty) {
        return 'Пользователь с таким email уже существует';
      }

      // Создание нового пользователя
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newUser = UserModel(
        id: userId,
        email: email,
        password: password, // В реальном приложении используйте хеширование!
        name: name,
        createdAt: DateTime.now(),
        role: role,
      );

      await usersBox.put(userId, newUser);

      // Автоматический вход после регистрации
      await login(email: email, password: password);

      return null; // Успешная регистрация
    } catch (e) {
      return 'Ошибка регистрации: $e';
    }
  }

  /// Вход пользователя
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final usersBox = Hive.box<UserModel>('users');

      final user = usersBox.values.firstWhere(
            (user) => user.email == email && user.password == password,
        orElse: () => UserModel(
          id: '',
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (user.id.isEmpty) {
        return 'Неверный email или пароль';
      }

      _currentUser = user;
      _isAuthenticated = true;

      // Сохранение текущего пользователя
      final settingsBox = Hive.box('settings');
      await settingsBox.put('currentUserId', user.id);

      notifyListeners();
      return null; // Успешный вход
    } catch (e) {
      return 'Ошибка входа: $e';
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;

    final settingsBox = Hive.box('settings');
    await settingsBox.delete('currentUserId');

    notifyListeners();
  }

  /// Вход по ID пользователя (используется для "войти как" в UI)
  Future<String?> loginById(String id) async {
    try {
      final usersBox = Hive.box<UserModel>('users');
      final user = usersBox.get(id);
      if (user == null) return 'Пользователь не найден';

      _currentUser = user;
      _isAuthenticated = true;

      final settingsBox = Hive.box('settings');
      await settingsBox.put('currentUserId', user.id);

      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка входа по ID: $e';
    }
  }

  /// Обновление профиля пользователя
  Future<String?> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      if (_currentUser == null) return 'Пользователь не авторизован';

      final usersBox = Hive.box<UserModel>('users');

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );

      await usersBox.put(_currentUser!.id, updatedUser);
      _currentUser = updatedUser;

      notifyListeners();
      return null; // Успешное обновление
    } catch (e) {
      return 'Ошибка обновления профиля: $e';
    }
  }
}