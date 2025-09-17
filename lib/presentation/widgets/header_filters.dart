import 'package:flutter/material.dart';
import 'filters_modal_content.dart';

class HeaderWithFilters extends StatelessWidget {
  /// Llamado cuando el usuario pulsa el header negro (para tus opciones de datos)
  final VoidCallback? onHeaderTap;

  /// Llamado cuando la modal de filtros devuelve el resultado (Map con searchQuery, etc.)
  final ValueChanged<Map<String, String?>?>? onFiltersApplied;

  const HeaderWithFilters({
    super.key,
    this.onHeaderTap,
    this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InkWell(
        onTap: onHeaderTap, // <- tocar el header negro abre opciones de datos
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              // Botón Buscar que abre la modal y devuelve el resultado al padre
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, String?>>(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    isScrollControlled: true,
                    builder: (context) => const FiltersModalContent(),
                  );
                  // Entrega el resultado a WorkPage
                  onFiltersApplied?.call(result);
                },
                icon: const Icon(Icons.filter_list, color: Colors.white),
                label: const Text("Buscar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
