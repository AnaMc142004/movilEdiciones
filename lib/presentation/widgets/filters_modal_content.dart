import 'package:flutter/material.dart';

class FiltersModalContent extends StatelessWidget {
  const FiltersModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  icon: Icons.book,
                  label: "Nombre de la obra",
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  icon: Icons.code,
                  label: "Código",
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 2
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  icon: Icons.person,
                  label: "Autor",
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  icon: Icons.business,
                  label: "Proveedor",
                  trailing: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 3
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  icon: Icons.camera_alt,
                  label: "ISBN",
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}