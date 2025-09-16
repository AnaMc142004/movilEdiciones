import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filters_modal_content.dart';

class HeaderWithFilters extends StatelessWidget {
  /// Se llama cuando se toca cualquier parte negra del header
  final VoidCallback? onHeaderTap;

  const HeaderWithFilters({super.key, this.onHeaderTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onHeaderTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      isScrollControlled: true,
                      builder: (context) => const FiltersModalContent(),
                    );
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  label: const Text(
                    "Buscar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
