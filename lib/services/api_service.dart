import 'dart:async';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

// ---------------------------------------------------------------------------
// Mock Interceptor — simulates network with realistic fake responses
// ---------------------------------------------------------------------------
class _MockInterceptor extends Interceptor {
  final _tasks = <String, Map<String, dynamic>>{
    '1': {
      'id': '1',
      'title': 'Design UI Mockups',
      'description': 'Create high-fidelity wireframes for all app screens.',
      'status': 'done',
      'due_date': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    },
    '2': {
      'id': '2',
      'title': 'Implement Auth Flow',
      'description': 'Build login and registration screens with validation.',
      'status': 'in_progress',
      'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    },
    '3': {
      'id': '3',
      'title': 'Write Unit Tests',
      'description':
          'Cover all service classes with at least 80% test coverage.',
      'status': 'todo',
      'due_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    },
    '4': {
      'id': '4',
      'title': 'API Integration',
      'description': 'Connect app to REST API endpoints for task CRUD.',
      'status': 'todo',
      'due_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    },
  };

  int _idCounter = 5;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final path = options.path;
    final method = options.method.toUpperCase();

    try {
      // ── AUTH ────────────────────────────────────────────────────────────
      if (path == '/auth/login' && method == 'POST') {
        final data = options.data as Map<String, dynamic>;
        final email = data['email'] as String;
        handler.resolve(
          _response(options, {
            'id': 'user_001',
            'email': email,
            'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          }),
        );
        return;
      }

      if (path == '/auth/register' && method == 'POST') {
        final data = options.data as Map<String, dynamic>;
        final email = data['email'] as String;
        handler.resolve(
          _response(options, {
            'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
            'email': email,
            'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          }),
        );
        return;
      }

      // ── TASKS ───────────────────────────────────────────────────────────
      if (path == '/tasks' && method == 'GET') {
        handler.resolve(_response(options, _tasks.values.toList()));
        return;
      }

      if (path == '/tasks' && method == 'POST') {
        final data = Map<String, dynamic>.from(options.data as Map);
        final id = '${_idCounter++}';
        data['id'] = id;
        _tasks[id] = data;
        handler.resolve(_response(options, data));
        return;
      }

      if (path.startsWith('/tasks/') && method == 'PUT') {
        final id = path.split('/').last;
        final data = Map<String, dynamic>.from(options.data as Map);
        data['id'] = id;
        _tasks[id] = data;
        handler.resolve(_response(options, data));
        return;
      }

      if (path.startsWith('/tasks/') && method == 'DELETE') {
        final id = path.split('/').last;
        _tasks.remove(id);
        handler.resolve(_response(options, {'message': 'Deleted'}));
        return;
      }

      handler.resolve(_response(options, {'message': 'Not found'}, 404));
    } catch (e) {
      handler.reject(
        DioException(requestOptions: options, error: e, message: e.toString()),
      );
    }
  }

  Response _response(RequestOptions options, dynamic data, [int status = 200]) {
    return Response(requestOptions: options, statusCode: status, data: data);
  }
}

// ---------------------------------------------------------------------------
// ApiService singleton
// ---------------------------------------------------------------------------
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(_MockInterceptor());

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Convenience parsers
  static UserModel parseUser(dynamic data) =>
      UserModel.fromJson(data as Map<String, dynamic>);

  static List<TaskModel> parseTasks(dynamic data) => (data as List)
      .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
      .toList();

  static TaskModel parseTask(dynamic data) =>
      TaskModel.fromJson(data as Map<String, dynamic>);
}
