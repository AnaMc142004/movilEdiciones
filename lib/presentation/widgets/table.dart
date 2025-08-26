import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BooksTable extends StatelessWidget {
  final List<Book> books;

  const BooksTable({super.key, required this.books});

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
            columnSpacing: 12,
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: const [
              DataColumn(label: Text("Nombre de la obra")),
              DataColumn(label: Text("Cantidad\nPropia")),
              DataColumn(label: Text("Cantidad\nConsignacion")),
              DataColumn(label: SizedBox()), // columna para el botón
            ],
            rows: books.asMap().entries.map((entry) {
              int index = entry.key;
              Book book = entry.value;

              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>((states) {
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
                  ),
                  DataCell(Text(book.cantidadPropia.toString())),
                  DataCell(Text(book.cantidadConsignacion.toString())),
                  DataCell(
                    IconButton(
                      icon: const Text('>'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Encabezado con icono + título + botón cerrar
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.bookmark,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          book.nombre,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // ISBN e ID
                                Text(
                                  "ISBN: ${book.isbn}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "ID: ${book.id}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Divider(
                                  height: 20,
                                  thickness: 1,
                                  color: Colors.green,
                                ),

                                // Editorial
                                RichText(
                                  text: TextSpan(
                                    text: "Editorial: ",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: book.editorial,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Cantidades
                                Text(
                                  "Cantidad propia: ${book.cantidadPropia}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Cantidad consignación: ${book.cantidadConsignacion}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),

                                // Total
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
                        );
                      },
                    ),
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
