import 'package:flutter/material.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/custom_button.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
            controller: _emailController,
            label: "Correo electronico",
            validator: (value) =>
                value == null || value.isEmpty ? "Ingresa tu correo" : null,
          ),

          SizedBox(height: fieldSpacing * 1.5),

          CustomButton(
            text: 'Enviar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Procesando login...")),
                );
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
