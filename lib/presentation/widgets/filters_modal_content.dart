import 'package:flutter/material.dart';

class FiltersModalContent extends StatefulWidget {
  const FiltersModalContent({super.key});

  @override
  State<FiltersModalContent> createState() => _FiltersModalContentState();
}

class _FiltersModalContentState extends State<FiltersModalContent> {
  final TextEditingController _isbnCtrl = TextEditingController();
  final FocusNode _isbnFocus = FocusNode();

  Future<void> openIsbnScanner() async {
    debugPrint('Abrir lector de ISBN…');
  }

  @override
  void dispose() {
    _isbnCtrl.dispose();
    _isbnFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom), 
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Material(
          color: Colors.white,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.4, 
            minChildSize: 0.4,
            maxChildSize: 0.95, 
            builder: (context, scrollController) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final twoCols = w >= 360; 
                  double itemWidth(int perRow) {
                    const gap = 8.0;
                    final totalGap = gap * (perRow - 1);
                    return (w - 32 /*padding x*/ - totalGap) / perRow;
                  }

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Wrap: se parte en otra fila automáticamente
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterButton(
                              icon: Icons.book,
                              label: "Nombre de la obra",
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterButton(
                              icon: Icons.code,
                              label: "Código",
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterButton(
                              icon: Icons.person,
                              label: "Autor",
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterButton(
                              icon: Icons.business,
                              label: "Proveedor",
                              trailing: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green,
                              ),
                              onTap: () {},
                            ),
                          ),

                          // ISBN ocupa toda la fila en pantallas chicas
                          SizedBox(
                            width: itemWidth(1),
                            child: _IsbnInputButton(
                              controller: _isbnCtrl,
                              focusNode: _isbnFocus,
                              onCameraTap: openIsbnScanner,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          ),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _IsbnInputButton extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCameraTap;

  const _IsbnInputButton({
    required this.controller,
    required this.focusNode,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.green),
            borderRadius: borderRadius,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            InkResponse(
              onTap: onCameraTap,
              radius: 24,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.camera_alt, color: Colors.green),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'ISBN',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
