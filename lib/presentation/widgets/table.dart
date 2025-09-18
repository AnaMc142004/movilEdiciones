import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BooksTable extends StatefulWidget {
  final List<Book> books;
  final void Function(Book)? onRowTap;

  const BooksTable({super.key, required this.books, this.onRowTap});

  @override
  State<BooksTable> createState() => _BooksTableState();
}

class _BooksTableState extends State<BooksTable> {
  final ScrollController _horizontalCtrl = ScrollController();
  @override
  void dispose() {
    _horizontalCtrl.dispose();
    super.dispose();
  }

  void _openDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bookmark, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                book.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "ISBN: ${book.isbn}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "ID: ${book.id}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 20, thickness: 1, color: Colors.green),
              RichText(
                text: TextSpan(
                  text: "Editorial: ",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: book.editorial,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "C.propia: ${book.cantidadPropia}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "C.consignación: ${book.cantidadConsignacion}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Total libros: ${book.total}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRowTap(BuildContext context, Book book) {
    if (widget.onRowTap != null) {
      widget.onRowTap!(book);
    } else {
      _openDetails(context, book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const columns = <DataColumn>[
      DataColumn(label: Text("Nombre de la obra")),
      DataColumn(label: Text("Propia")),
      DataColumn(label: Text("Consignacion")),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalCtrl,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: size.width),
            child: Theme(
              data: Theme.of(context).copyWith(
                dataTableTheme: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(Colors.green[700]),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: DataTable(
                showCheckboxColumn: false,
                columnSpacing: 12,
                columns: columns,
                rows: const [],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalCtrl,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: size.width),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 12,
                  headingRowHeight: 0,
                  columns: columns,
                  rows: widget.books.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Book book = entry.value;

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (states) => index.isEven ? Colors.grey[100] : null,
                      ),
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              book.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () => _handleRowTap(context, book),
                        ),
                        DataCell(
                          Text(book.cantidadPropia.toString()),
                          onTap: () => _handleRowTap(context, book),
                        ),
                        DataCell(
                          Text(book.cantidadConsignacion.toString()),
                          onTap: () => _handleRowTap(context, book),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
