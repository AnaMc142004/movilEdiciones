// data/services/book_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BookService {
  final String baseUrl = 'https://backediciones.com/api';

  Future<List<Book>> fetchBooks() async {
    final url = Uri.parse('$baseUrl/books/all');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return Book(
          id: (item['id_autoincremental'] ?? '').toString(),
          nombre: item['name'] ?? 'Sin nombre',
          isbn: (item['isbn'] ?? '').toString(),
          editorial:
              (item['publishing.provider.corporate_name'] ?? 'Sin editorial')
                  .toString(),
          cantidadPropia: item['own_quantity_total'] ?? 0,
          cantidadConsignacion: item['consignment_quantity_total'] ?? 0,
          total: item['cost'] ?? 0,
        );
      }).toList();
    } else {
      throw Exception('Error al obtener libros: ${response.statusCode}');
    }
  }
}
