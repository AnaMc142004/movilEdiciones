import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filters_modal_content.dart';

class HeaderWithFilters extends StatelessWidget {
  const HeaderWithFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  builder: (context) {
                    return const FiltersModalContent();
                  },
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
    );
  }
}
