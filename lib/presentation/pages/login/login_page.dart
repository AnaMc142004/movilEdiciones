import 'package:ediciones_hispanicas/presentation/pages/login/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../widgets/menu_button.dart';

double responsiveSize(
  BuildContext context,
  double base, {
  double? min,
  double? max,
}) {
  final size = MediaQuery.of(context).size;
  final scale = size.width / 375;
  double newSize = base * scale;

  if (min != null && newSize < min) return min;
  if (max != null && newSize > max) return max;
  return newSize;
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = insets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: insets.bottom),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  if (isWide && !isKeyboardOpen) {
                    return Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: _LeftPanel(showLogo: true),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 400),
                                child: LoginForm(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isKeyboardOpen) ...[
                            const _LeftPanel(
                              showLogo: true,
                              showWelcome: false,
                            ),
                            const SizedBox(height: 24),
                          ],
                          const _WelcomeText(), // ← nunca desaparece
                          const SizedBox(height: 24),
                          const LoginForm(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final bool showLogo;
  final bool showWelcome;

  const _LeftPanel({this.showLogo = false, this.showWelcome = true, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showLogo) ...[
          SizedBox(height: size.height * 0.08),
          Image.asset('assets/images/edi.png', height: size.height * 0.1),
          SizedBox(height: size.height * 0.06),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                icon: Icons.login,
                text: "Iniciar\nSesión",
                onTap: () {},
              ),
              const SizedBox(width: 16),
              MenuButton(
                icon: Icons.help_outline,
                text: "¿Olvidó la\ncontraseña?",
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.forgotPassword),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.06),
        ],
        if (showWelcome) const _WelcomeText(),
      ],
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Bienvenido",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 32, min: 18, max: 28),
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ingresa a tu cuenta y continúa aprovechando\n"
          "nuestras herramientas financieras para operar\n"
          "con éxito.",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 13, min: 11, max: 18),
          ),
        ),
      ],
    );
  }
}
