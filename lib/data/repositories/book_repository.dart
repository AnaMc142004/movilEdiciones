// lib/data/repositories/book_repository.dart
import '../services/book_service.dart' as svc; // <- alias para evitar choques de nombres
import '../models/book_model.dart';

class BookRepository {
  final svc.BookService _service;

  BookRepository({required svc.BookService service}) : _service = service;

  void startSession() => _service.startSession();
  void endSession() => _service.endSession();
  bool get isSessionActive => _service.isSessionActive;

  Future<void> ensureLocalData() => _service.ensureLocalData();

  Future<void> refreshAllFromAPI() => _service.refreshAllFromAPI();

  Future<void> clearCache() => _service.clearCache();
  Future<svc.PageResult<Book>> getBooksPage({
    required int page,
    required int pageSize,
    bool? hasConsignment,
    bool? hasOwn,
    String? searchQuery,
    bool force = false, // si true, fuerza una descarga completa antes de leer DB
  }) async {
    if (force) {
      await _service.refreshAllFromAPI();
    } else {
      await _service.ensureLocalData();
    }

    return _service.queryBooksPageFromDB(
      page: page,
      pageSize: pageSize,
      hasConsignment: hasConsignment,
      hasOwn: hasOwn,
      searchQuery: searchQuery,
    );
  }

  // Estadísticas rápidas (en memoria, a partir de una lista ya cargada/paginada)
  Map<String, int> getBookStats(List<Book> books) {
    int totalConsignment = 0;
    int totalOwn = 0;
    int booksWithConsignment = 0;
    int booksWithOwn = 0;

    for (final book in books) {
      totalConsignment += book.cantidadConsignacion;
      totalOwn += book.cantidadPropia;
      if (book.cantidadConsignacion > 0) booksWithConsignment++;
      if (book.cantidadPropia > 0) booksWithOwn++;
    }

    return {
      'totalBooks': books.length,
      'totalConsignment': totalConsignment,
      'totalOwn': totalOwn,
      'booksWithConsignment': booksWithConsignment,
      'booksWithOwn': booksWithOwn,
    };
  }

  Book? findBookById(List<Book> books, String id) {
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
