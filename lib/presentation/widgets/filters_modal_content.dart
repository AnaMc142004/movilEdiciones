import 'package:flutter/material.dart';

class FiltersModalContent extends StatefulWidget {
  const FiltersModalContent({super.key});

  @override
  State<FiltersModalContent> createState() => _FiltersModalContentState();
}

class _FiltersModalContentState extends State<FiltersModalContent> {
  // Controladores (para poder copiar/pegar fácilmente)
  final TextEditingController _obraCtrl = TextEditingController();
  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _autorCtrl = TextEditingController();
  final TextEditingController _proveedorCtrl = TextEditingController();
  final TextEditingController _isbnCtrl = TextEditingController();

  final FocusNode _isbnFocus = FocusNode();

  @override
  void dispose() {
    _obraCtrl.dispose();
    _codigoCtrl.dispose();
    _autorCtrl.dispose();
    _proveedorCtrl.dispose();
    _isbnCtrl.dispose();
    _isbnFocus.dispose();
    super.dispose();
  }

  // Si tienes lector de códigos, engancha aquí
  Future<void> _openIsbnScanner() async {
    // TODO: Integrar cámara/escaner
    debugPrint('Abrir lector de ISBN…');
  }

  void _clearAll() {
    _obraCtrl.clear();
    _codigoCtrl.clear();
    _autorCtrl.clear();
    _proveedorCtrl.clear();
    _isbnCtrl.clear();
    setState(() {}); // refresca placeholders si hace falta
  }

  String? _editorialFromProveedor(String? prov) {
    if (prov == null || prov.trim().isEmpty) return null;
    // Si más adelante necesitas mapear proveedor->editorial, hazlo aquí.
    return prov.trim();
  }

  void _apply() {
    final obra = _obraCtrl.text.trim();
    final codigo = _codigoCtrl.text.trim();
    final autor = _autorCtrl.text.trim();
    final proveedor = _proveedorCtrl.text.trim();
    final isbn = _isbnCtrl.text.trim();

    final pieces = <String>[
      if (obra.isNotEmpty) obra,
      if (_editorialFromProveedor(proveedor) != null)
        _editorialFromProveedor(proveedor)!,
      if (isbn.isNotEmpty) isbn,
      if (autor.isNotEmpty) autor,
      if (codigo.isNotEmpty) codigo,
      if (proveedor.isNotEmpty) proveedor,
    ];

    final result = <String, String?>{
      'isbn': isbn.isEmpty ? null : isbn,
      'obra': obra.isEmpty ? null : obra,
      'editorial': _editorialFromProveedor(proveedor),
      'autor': autor.isEmpty ? null : autor,
      'proveedor': proveedor.isEmpty ? null : proveedor,
      'codigo': codigo.isEmpty ? null : codigo,
      'searchQuery': pieces.isEmpty ? null : pieces.join(' '),
    };

    Navigator.pop(context, result);
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
                  final twoCols = w >= 360; // 2 por fila cuando hay espacio

                  double itemWidth(int perRow) {
                    const gap = 8.0;
                    final totalGap = gap * (perRow - 1);
                    return (w - 32 /*padding x*/ - totalGap) / perRow;
                  }

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Handle
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

                      // Inputs en la misma modal (sin abrir otra)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterTextField(
                              icon: Icons.book,
                              hint: 'Nombre de la obra',
                              controller: _obraCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterTextField(
                              icon: Icons.code,
                              hint: 'Código',
                              controller: _codigoCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterTextField(
                              icon: Icons.person,
                              hint: 'Autor',
                              controller: _autorCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterTextField(
                              icon: Icons.business,
                              hint: 'Proveedor',
                              controller: _proveedorCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          // ISBN con botón de cámara
                          SizedBox(
                            width: itemWidth(1),
                            child: _IsbnInlineField(
                              controller: _isbnCtrl,
                              focusNode: _isbnFocus,
                              onCameraTap: _openIsbnScanner,
                              onSubmitted: (_) => _apply(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearAll,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Limpiar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _apply,
                              icon: const Icon(Icons.search, color: Colors.white),
                              label: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _FilterTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;

  const _FilterTextField({
    required this.icon,
    required this.hint,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IsbnInlineField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCameraTap;
  final ValueChanged<String>? onSubmitted;

  const _IsbnInlineField({
    required this.controller,
    required this.focusNode,
    required this.onCameraTap,
    this.onSubmitted,
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
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
