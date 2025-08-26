import '../models/login_model.dart';
import '../services/login_service.dart';

class LoginRepository {
  final LoginService service;

  LoginRepository({required this.service});

  Future<LoginResponse> login(String username, String password) async {
    final response = await service.login(username, password);
    return LoginResponse.fromJson(response);
  }
}
