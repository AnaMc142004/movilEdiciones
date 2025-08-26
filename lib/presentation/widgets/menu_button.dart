import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 480;

    return SizedBox(
      // 📏 tamaños más pequeños para móvil
      width: isMobile ? 100 : responsiveSize(context, 150, min: 130, max: 200),
      height: isMobile ? 75 : responsiveSize(context, 110, min: 90, max: 140),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 12, max: 20),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 6 : 8,
            horizontal: isMobile ? 6 : 8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.green,
              size: isMobile
                  ? 22 // 👈 icono más pequeño
                  : responsiveSize(context, 32, min: 24, max: 40),
            ),
            const SizedBox(height: 4), // 👈 menos espacio
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: isMobile
                    ? 10 // 👈 letra más pequeña
                    : responsiveSize(context, 16, min: 14, max: 20),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper responsivo
double responsiveSize(BuildContext context, double base,
    {double? min, double? max}) {
  final size = MediaQuery.of(context).size;
  final scale = size.width / 375;
  double newSize = base * scale;

  if (min != null && newSize < min) return min;
  if (max != null && newSize > max) return max;
  return newSize;
}
