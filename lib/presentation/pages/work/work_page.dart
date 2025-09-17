import 'package:flutter/material.dart';
import 'dart:async';
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
  String? errorMessage;

  bool obrasConsignacion = false;
  bool obrasPropias = false;
  String? _searchQuery;

  late final BookRepository repository;

  int _page = 1;
  final int _pageSize = 200;
  bool _hasMore = false;
  bool _loadingMore = false;

  Timer? _filterTimer;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    repository = BookRepository(service: BookService());
    repository.startSession();
    _fetchFirstPage();
  }

  Future<void> _fetchFirstPage({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final pageResult = await repository.getBooksPage(
        page: 1,
        pageSize: _pageSize,
        hasConsignment: obrasConsignacion ? true : null,
        hasOwn: obrasPropias ? true : null,
        searchQuery: _searchQuery,
        force: forceRefresh,
      );

      if (!mounted) return;

      if (_isFirstLoad && pageResult.items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pageResult.items.length} libros cargados'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _isFirstLoad = false;
      }

      setState(() {
        _page = 1;
        _hasMore = pageResult.hasMore;
        books = List<Book>.from(pageResult.items);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    try {
      final nextPage = _page + 1;
      final pageResult = await repository.getBooksPage(
        page: nextPage,
        pageSize: _pageSize,
        hasConsignment: obrasConsignacion ? true : null,
        hasOwn: obrasPropias ? true : null,
        searchQuery: _searchQuery, // <- mantiene texto
      );
      if (!mounted) return;

      setState(() {
        _page = nextPage;
        _hasMore = pageResult.hasMore;
        books.addAll(pageResult.items);
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        errorMessage ??= 'No se pudo cargar más libros';
      });
    }
  }

  void _onFilterChanged(bool isConsignacion, bool value) {
    _filterTimer?.cancel();
    setState(() {
      if (isConsignacion) {
        obrasConsignacion = value;
      } else {
        obrasPropias = value;
      }
    });
    // debounce pequeño
    _filterTimer = Timer(const Duration(milliseconds: 120), () {
      _fetchFirstPage();
    });
  }

  Future<void> _refreshFromServer() async {
    await _fetchFirstPage(forceRefresh: true);
  }

  Future<void> _showCacheOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CacheOptionsSheet(
        repository: repository,
        bookStats: _calcStatsLocal(books),
      ),
    );

    if (result == 'refresh') {
      _refreshFromServer();
    } else if (result == 'clear_cache') {
      await repository.clearCache();
      setState(() {
        books.clear();
        _page = 1;
        _hasMore = false;
      });
      await _fetchFirstPage(forceRefresh: true);
    }
  }

  Map<String, int> _calcStatsLocal(List<Book> list) {
    int totalCons = 0, totalOwn = 0, withCons = 0, withOwn = 0;
    for (final b in list) {
      totalCons += b.cantidadConsignacion;
      totalOwn += b.cantidadPropia;
      if (b.cantidadConsignacion > 0) withCons++;
      if (b.cantidadPropia > 0) withOwn++;
    }
    return {
      'totalBooks': list.length,
      'totalConsignment': totalCons,
      'totalOwn': totalOwn,
      'booksWithConsignment': withCons,
      'booksWithOwn': withOwn,
    };
  }

  void _onFiltersApplied(Map<String, String?>? result) {
    final newQuery = result?['searchQuery'];
    setState(() {
      _searchQuery = (newQuery == null || newQuery.trim().isEmpty)
          ? null
          : newQuery.trim();
    });
    _fetchFirstPage();
  }

  void _showBookDetails(Book book) {
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
                  const Icon(Icons.bookmark, color: Colors.green, size: 28),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
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
              Text("ISBN: ${book.isbn}", style: const TextStyle(fontSize: 14)),
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
              const SizedBox(height: 12),
              Text(
                "Cantidad propia: ${book.cantidadPropia}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Cantidad consignación: ${book.cantidadConsignacion}",
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithFilters(
              onHeaderTap: _showCacheOptions,
              onFiltersApplied: _onFiltersApplied,
            ),
            const SizedBox(height: 5),
            Row(
            
              children: [
                _CheckboxFilter(
                  value: obrasConsignacion,
                  label: "Consignación",
                  isEnabled: !isLoading,
                  onChanged: (v) => _onFilterChanged(true, v ?? false),
                ),
                const SizedBox(width: 16),
                _CheckboxFilter(
                  value: obrasPropias,
                  label: "Propias",
                  isEnabled: !isLoading,
                  onChanged: (v) => _onFilterChanged(false, v ?? false),
                ),
               
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }
    if (errorMessage != null) {
      return _ErrorWidget(
        message: errorMessage!,
        onRetry: () => _fetchFirstPage(),
        onClose: () => setState(() => errorMessage = null),
        showCacheOption: books.isNotEmpty,
        onLoadFromCache: books.isNotEmpty
            ? () => setState(() => errorMessage = null)
            : null,
      );
    }
    if (books.isEmpty) {
      return _EmptyStateWidget(onRefresh: () => _fetchFirstPage());
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchFirstPage(forceRefresh: true),
            child: BooksTable(
              books: books,
              onRowTap:
                  _showBookDetails, // asegúrate de que BooksTable acepte este callback
            ),
          ),
        ),
        if (_hasMore)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // fondo verde
                    foregroundColor: Colors.white, // texto e icono en blanco
                    disabledBackgroundColor: Colors.green.shade300,
                    disabledForegroundColor: Colors.white70,
                  ),
                  onPressed: _loadingMore ? null : _loadNextPage,
                  icon: _loadingMore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white, // spinner blanco
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _loadingMore ? 'Cargando...' : 'Cargar más obras',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _filterTimer?.cancel();
    repository.endSession();
    super.dispose();
  }
}

class _CheckboxFilter extends StatelessWidget {
  final bool value;
  final String label;
  final bool isEnabled;
  final ValueChanged<bool?> onChanged;

  const _CheckboxFilter({
    required this.value,
    required this.label,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: isEnabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: isEnabled ? onChanged : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: isEnabled ? null : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final bool showCacheOption;
  final VoidCallback? onLoadFromCache;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
    required this.onClose,
    this.showCacheOption = false,
    this.onLoadFromCache,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                  if (showCacheOption && onLoadFromCache != null)
                    ElevatedButton(
                      onPressed: onLoadFromCache,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Usar caché local'),
                    ),
                  OutlinedButton(
                    onPressed: onClose,
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyStateWidget({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay libros disponibles',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Cargar libros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CacheOptionsSheet extends StatelessWidget {
  final BookRepository repository;
  final Map<String, int> bookStats;

  const _CacheOptionsSheet({required this.repository, required this.bookStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opciones de datos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Estadísticas de lo cargado en memoria (rápidas)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado actual:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sesión activa: ${repository.isSessionActive ? "Sí" : "No"}',
                ),
                Text(
                  'Total de libros (cargados): ${bookStats['totalBooks'] ?? 0}',
                ),
                Text(
                  'Libros en consignación: ${bookStats['booksWithConsignment'] ?? 0}',
                ),
                Text('Libros propios: ${bookStats['booksWithOwn'] ?? 0}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Actualizar desde servidor'),
            subtitle: const Text('Obtener los datos más recientes'),
            onTap: () => Navigator.pop(context, 'refresh'),
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Limpiar caché'),
            subtitle: const Text('Borrar datos guardados localmente'),
            onTap: () => Navigator.pop(context, 'clear_cache'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
