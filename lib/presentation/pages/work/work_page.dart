import 'package:flutter/material.dart';
import '../../widgets/table.dart';
import '../../widgets/header_filters.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/services/book_service.dart';
import '../../../data/models/book_model.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  List<Book> books = [];
  bool isLoading = true;

  bool obrasConsignacion = false;
  bool obrasPropias = false;

  // Inicializamos repository con el service
  late final BookRepository repository;

  @override
  void initState() {
    super.initState();
    repository = BookRepository(service: BookService());
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);

    try {
      final fetchedBooks = await repository.getBooks();
      setState(() {
        books = fetchedBooks;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar libros: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithFilters(),
            const SizedBox(height: 8),
            // Checkboxes
            Row(
              children: [
                StatefulBuilder(
                  builder: (context, setState) => Row(
                    children: [
                      Checkbox(
                        value: obrasConsignacion,
                        onChanged: (value) {
                          setState(() {
                            obrasConsignacion = value!;
                          });
                        },
                      ),
                      const Text("Obras en consignación"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) => Row(
                    children: [
                      Checkbox(
                        value: obrasPropias,
                        onChanged: (value) {
                          setState(() {
                            obrasPropias = value!;
                          });
                        },
                      ),
                      const Text("Obras propias"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabla
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BooksTable(books: books),
            ),
          ],
        ),
      ),
    );
  }
}
