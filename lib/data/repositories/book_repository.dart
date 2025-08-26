// data/repositories/book_repository.dart
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookRepository {
  final BookService service;

  BookRepository({required this.service});

  Future<List<Book>> getBooks() async {
    return await service.fetchBooks();
  }
}
