// lib/data/repositories/book_repository.dart
import '../services/book_service.dart' as svc;
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

  Future<svc.BookStats> getBookStats() => _service.getBookStats();

  Future<svc.PageResult<Book>> getBooksPage({
    required int page,
    required int pageSize,
    bool? hasConsignment,
    bool? hasOwn,
    String? searchQuery,
    bool force = false, 
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

  // Método helper para buscar un libro específico por ID
  Future<Book?> findBookById(String id) async {
    final result = await _service.queryBooksPageFromDB(
      page: 1,
      pageSize: 1,
      searchQuery: id, 
    );
    
    return result.items.isNotEmpty ? result.items.first : null;
  }

  Future<int> getTotalBooksCount() async {
    final stats = await getBookStats();
    return stats.totalBooks;
  }

  String formatPageInfo(svc.PageResult<Book> result) {
    return result.pageInfo;
  }

  String formatFilteredInfo(svc.PageResult<Book> result) {
    final stats = result.filteredStats;
    if (stats == null) return '';
    
    return "Encontrados: ${stats.totalFiltered} libros";
  }
}