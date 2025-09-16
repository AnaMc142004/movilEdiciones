import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BooksTable extends StatelessWidget {
  final List<Book> books;

  const BooksTable({super.key, required this.books});

  void _openDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: const [
                    Icon(Icons.bookmark, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                  ]),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(book.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("ISBN: ${book.isbn}", style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text("ID: ${book.id}", style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
              const Divider(height: 20, thickness: 1, color: Colors.green),
              RichText(
                text: TextSpan(
                  text: "Editorial: ",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [TextSpan(text: book.editorial, style: const TextStyle(fontWeight: FontWeight.bold))],
                ),
              ),
              const SizedBox(height: 12),
              Text("Cantidad propia: ${book.cantidadPropia}", style: const TextStyle(fontSize: 16)),
              Text("Cantidad consignación: ${book.cantidadConsignacion}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Total libros: ${book.total}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: size.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            showCheckboxColumn: false, // <- evita la columna de checkboxes
            columnSpacing: 12,
            headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
            columns: const [
              DataColumn(label: Text("Nombre de la obra")),
              DataColumn(label: Text("Cantidad\nPropia")),
              DataColumn(label: Text("Cantidad\nConsignacion")),
           
            ],
            rows: books.asMap().entries.map((entry) {
              final int index = entry.key;
              final Book book = entry.value;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (index % 2 == 0) return Colors.grey[100];
                  return null;
                }),
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
                    onTap: () => _openDetails(context, book),
                  ),
                  DataCell(
                    Text(book.cantidadPropia.toString()),
                    onTap: () => _openDetails(context, book),
                  ),
                  DataCell(
                    Text(book.cantidadConsignacion.toString()),
                    onTap: () => _openDetails(context, book),
                  ),
               
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
