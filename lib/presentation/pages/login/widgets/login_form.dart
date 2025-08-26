import 'package:flutter/material.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../../data/services/login_service.dart';
import '../../../../data/repositories/login_repository.dart';
import '../../../../data/models/login_model.dart';
import '../../../routes/app_routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginRepository repository;

  @override
  void initState() {
    super.initState();
    repository = LoginRepository(service: LoginService());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fieldSpacing = size.height * 0.02;
    final buttonHeight = size.height * 0.06;
    final fieldWidth = size.width * 0.8;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInputField(
            controller: _userController,
            label: "Usuario",
            validator: (value) =>
                value == null || value.isEmpty ? "Ingresa tu usuario" : null,
          ),
          SizedBox(height: fieldSpacing),
          CustomInputField(
            controller: _passwordController,
            label: "Contraseña",
            isPassword: true,
            validator: (value) =>
                value == null || value.isEmpty ? "Ingresa tu contraseña" : null,
          ),
          SizedBox(height: fieldSpacing * 1.5),
          CustomButton(
            text: 'Ingresar',
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final LoginResponse loginData = await repository.login(
                    _userController.text,
                    _passwordController.text,
                  );

                  print('Token: ${loginData.accessToken}');
                  print('Usuario: ${loginData.user.name}');

                  Navigator.pushNamed(context, AppRoutes.work);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            width: fieldWidth,
            height: buttonHeight,
          ),
        ],
      ),
    );
  }
}
