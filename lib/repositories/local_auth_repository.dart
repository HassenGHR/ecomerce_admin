import 'dart:convert';
import 'package:admin/models/user_model.dart';
import 'package:admin/repositories/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements UserRepository {
  final SharedPreferences _prefs;
  static const String _userKey = 'user_data';
  static const String _usersKey = 'users_list';
  static const String _fcmTokenKey = 'fcm_token';

  LocalAuthRepository(this._prefs);

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    List<UserModel> users = await _getAllUsers();
    return users.firstWhere((user) => user.phone == phone);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, user.toJson());
    List<UserModel> users = await _getAllUsers();
    users.removeWhere((u) => u.email == user.email);
    users.add(user);
    await _prefs.setString(
        _usersKey, jsonEncode(users.map((u) => u.toMap()).toList()));
  }

  @override
  Future<UserModel?> getUser() async {
    final userDataString = _prefs.getString(_userKey);
    return userDataString != null ? UserModel.fromJson(userDataString) : null;
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_fcmTokenKey, token);
  }

  @override
  Future<String?> getFCMToken() async {
    return _prefs.getString(_fcmTokenKey);
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_userKey);
  }

  Future<List<UserModel>> _getAllUsers() async {
    final usersDataString = _prefs.getString(_usersKey);
    if (usersDataString == null) return [];
    List<dynamic> usersJson = jsonDecode(usersDataString);
    return usersJson.map((json) => UserModel.fromMap(json)).toList();
  }

  @override
  Future<List<UserModel>> fetchCustomers() async {
    return await _getAllUsers();
  }
}
