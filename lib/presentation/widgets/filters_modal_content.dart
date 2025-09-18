import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FiltersModalContent extends StatefulWidget {
  const FiltersModalContent({super.key});

  @override
  State<FiltersModalContent> createState() => _FiltersModalContentState();
}

class _FiltersModalContentState extends State<FiltersModalContent> {
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

  Future<void> _openIsbnScanner() async {
    try {
      // Navegar a la pantalla de escáner
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _BarcodeScannerScreen(
            onBarcodeDetected: (String barcode) {
              // Validar que sea un ISBN válido (10 o 13 dígitos)
              if (_isValidISBN(barcode)) {
                setState(() {
                  _isbnCtrl.text = barcode;
                });
                
                // Mostrar mensaje de éxito
                _showSnackBar('ISBN escaneado correctamente: $barcode', Colors.green);
                
                debugPrint('ISBN escaneado: $barcode');
              } else {
                // El código escaneado no es un ISBN válido
                _showSnackBar('El código escaneado no es un ISBN válido', Colors.orange);
                debugPrint('Código no válido escaneado: $barcode');
              }
              
              Navigator.of(context).pop(); // Cerrar escáner
            },
          ),
        ),
      );

    } catch (e) {
      // Otros errores
      debugPrint('Error inesperado: $e');
      _showSnackBar('Error inesperado al escanear', Colors.red);
    }
  }

  // Validar formato ISBN (básico)
  bool _isValidISBN(String code) {
    // Remover espacios y guiones
    final cleanCode = code.replaceAll(RegExp(r'[\s-]'), '');
    
    // Verificar que sea numérico y tenga 10 o 13 dígitos
    if (!RegExp(r'^\d{10}$|^\d{13}$').hasMatch(cleanCode)) {
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    _obraCtrl.clear();
    _codigoCtrl.clear();
    _autorCtrl.clear();
    _proveedorCtrl.clear();
    _isbnCtrl.clear();
    setState(() {});
  }

  String? _editorialFromProveedor(String? prov) {
    if (prov == null || prov.trim().isEmpty) return null;
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
                  final twoCols = w >= 360; 

                  double itemWidth(int perRow) {
                    const gap = 8.0;
                    final totalGap = gap * (perRow - 1);
                    return (w - 32 - totalGap) / perRow;
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
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth(twoCols ? 2 : 1),
                            child: _FilterTextField(
                              icon: Icons.code,
                              hint: 'Código',
                              controller: _codigoCtrl,
                              textInputAction: TextInputAction.search,
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

// Pantalla del escáner de códigos de barras
class _BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const _BarcodeScannerScreen({required this.onBarcodeDetected});

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool isDetected = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear ISBN'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.camera_front),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (!isDetected) {
                isDetected = true;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    widget.onBarcodeDetected(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          // Overlay con instrucciones
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Apunta la cámara hacia el código de barras del libro',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
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