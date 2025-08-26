import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/forgot_password_form.dart';
import '../../routes/app_routes.dart';
import '../../widgets/menu_button.dart';

// ✅ Helper responsivo (mismo que login)
double responsiveSize(BuildContext context, double base,
    {double? min, double? max}) {
  final size = MediaQuery.of(context).size;
  final scale = size.width / 375;
  double newSize = base * scale;

  if (min != null && newSize < min) return min;
  if (max != null && newSize > max) return max;
  return newSize;
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // 💻 Tablet/desktop → 2 paneles
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _LeftPanel(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: const ForgotPasswordForm(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // 📱 Móvil → columna
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _LeftPanel(),
                      const SizedBox(height: 24),
                      const ForgotPasswordForm(),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 🔹 Panel izquierdo con títulos y botones
class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: size.height * 0.1),

        Text(
          "EDICIONES",
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 60, min: 24, max: 50),
            fontWeight: FontWeight.w900,
            color: const Color.fromARGB(255, 38, 87, 40),
            letterSpacing: -1,
            height: 1,
          ),
        ),
        Text(
          "HISPÁNICAS",
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 55, min: 22, max: 45),
            fontWeight: FontWeight.w900,
            color: const Color.fromARGB(255, 38, 87, 40),
            letterSpacing: -1,
            height: 1,
          ),
        ),

        SizedBox(height: size.height * 0.05),

        // ✅ Usamos el mismo _MenuButton del login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              icon: Icons.login,
              text: "Iniciar\nSesión",
              onTap: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
            const SizedBox(width: 16),
            MenuButton(
              icon: Icons.help_outline,
              text: "¿Olvidó la\ncontraseña?",
              onTap: () {},
            ),
          ],
        ),

        SizedBox(height: size.height * 0.05),

        Text(
          "Recuperar contraseña",
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 32, min: 18, max: 28),
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ingresa tu correo electrónico y te enviaremos\n"
          "instrucciones para restablecer tu contraseña.",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: responsiveSize(context, 13, min: 11, max: 18),
          ),
        ),
      ],
    );
  }
}
