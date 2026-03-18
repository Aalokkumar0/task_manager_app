import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    final response = await ApiService.instance.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final user = ApiService.parseUser(response.data);
    await _persistUser(user);
    ApiService.instance.setAuthToken(user.token);
    return user;
  }

  Future<UserModel> register(String email, String password) async {
    final response = await ApiService.instance.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    final user = ApiService.parseUser(response.data);
    await _persistUser(user);
    ApiService.instance.setAuthToken(user.token);
    return user;
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userEmailKey);
    ApiService.instance.clearAuthToken();
  }

  /// Returns the stored user if a valid token exists, otherwise null.
  Future<UserModel?> getStoredUser() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    final id = await _storage.read(key: AppConstants.userIdKey);
    final email = await _storage.read(key: AppConstants.userEmailKey);
    if (token == null || id == null || email == null) return null;
    ApiService.instance.setAuthToken(token);
    return UserModel(id: id, email: email, token: token);
  }

  Future<void> _persistUser(UserModel user) async {
    await _storage.write(key: AppConstants.tokenKey, value: user.token);
    await _storage.write(key: AppConstants.userIdKey, value: user.id);
    await _storage.write(key: AppConstants.userEmailKey, value: user.email);
  }
}
