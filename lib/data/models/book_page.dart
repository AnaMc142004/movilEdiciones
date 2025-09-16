import 'book_model.dart';
class BookPage {
  final List<Book> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  const BookPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}