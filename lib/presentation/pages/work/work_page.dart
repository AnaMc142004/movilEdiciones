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
  // Datos en pantalla
  List<Book> books = []; // acumulado de páginas cargadas
  bool isLoading = true;

  // Filtros activos
  bool obrasConsignacion = false;
  bool obrasPropias = false;
  String? _searchText;

  // Repo
  late final BookRepository repository;

  // Estado/UI
  String? errorMessage;
  Timer? _filterTimer;
  bool _isFirstLoad = true;

  // Paginación
  int _page = 1;
  final int _pageSize = 200;
  bool _hasMore = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    repository = BookRepository(service: BookService());
    repository.startSession();
    _loadFirstPage();
  }

  // Carga la primera página según filtros actuales DESDE BD
  Future<void> _loadFirstPage({bool forceRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = await repository.getBooksPage(
        page: 1,
        pageSize: _pageSize,
        hasConsignment: obrasConsignacion ? true : null,
        hasOwn: obrasPropias ? true : null,
        searchQuery: _searchText,
        force: forceRefresh, // solo descarga si force=true
      );

      if (!mounted) return;

      if (_isFirstLoad && res.items.isNotEmpty) {
        _showCacheInfo(res.items.length);
        _isFirstLoad = false;
      }

      setState(() {
        _page = 1;
        _hasMore = res.hasMore;
        books = List<Book>.from(res.items);
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

  // Cargar siguiente página según filtros
  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    try {
      final res = await repository.getBooksPage(
        page: _page + 1,
        pageSize: _pageSize,
        hasConsignment: obrasConsignacion ? true : null,
        hasOwn: obrasPropias ? true : null,
        searchQuery: _searchText,
      );

      if (!mounted) return;

      setState(() {
        _page += 1;
        _hasMore = res.hasMore;
        books.addAll(res.items);
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        errorMessage ??= 'No se pudo cargar más libros';
      });
    }
  }

  // Cambios de filtro -> recargar página 1 DESDE BD
  void _onFilterChanged(bool isConsignacion, bool value) {
    if (!mounted) return;
    _filterTimer?.cancel();

    setState(() {
      if (isConsignacion) {
        obrasConsignacion = value;
      } else {
        obrasPropias = value;
      }
    });

    _filterTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) _loadFirstPage();
    });
  }

  // Si usas un campo de búsqueda, llama a esto
  void _onSearchChanged(String value) {
    _searchText = value.trim().isEmpty ? null : value.trim();
    _filterTimer?.cancel();
    _filterTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) _loadFirstPage();
    });
  }

  Future<void> _refreshFromServer() async {
    // Fuerza descarga completa y luego lee desde BD
    await _loadFirstPage(forceRefresh: true);
  }

  Future<void> _showCacheOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CacheOptionsSheet(
        repository: repository,
        bookStats: repository.getBookStats(books),
      ),
    );

    if (result == 'refresh') {
      await _refreshFromServer();
    } else if (result == 'clear_cache') {
      await _clearCache();
    }
  }

  Future<void> _clearCache() async {
    try {
      await repository.clearCache();
      setState(() {
        books.clear();
        _page = 1;
        _hasMore = false;
      });
      // Tras limpiar, intenta descargar todo nuevamente:
      await _loadFirstPage(forceRefresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caché limpiado y datos actualizados'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al limpiar caché: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCacheInfo(int booksCount) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$booksCount libros cargados (desde BD local)'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _showBookDetails(Book book) {
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
              Text("ISBN: ${book.isbn}", style: const TextStyle(fontSize: 14)),
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: tocar el área negra abre opciones de datos
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: HeaderWithFilters(
                          onHeaderTap: _showCacheOptions,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FiltersRow(
                    obrasConsignacion: obrasConsignacion,
                    obrasPropias: obrasPropias,
                    isLoading: isLoading,
                    filteredCount: books.length, // cantidad mostrada en pantalla
                    totalCount: books.length,    // (si quieres total real, puedes consultar totalCount del PageResult inicial)
                    onFilterChanged: _onFilterChanged,
                  ),
                ],
              ),
            ),
            // CONTENIDO
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _LoadingWidget(
        isFirstLoad: _isFirstLoad,
        sessionActive: repository.isSessionActive,
      );
    }

    if (errorMessage != null) {
      return _ErrorWidget(
        message: errorMessage!,
        onRetry: () => _loadFirstPage(),
        onClose: () => setState(() => errorMessage = null),
        showCacheOption: books.isNotEmpty,
        onLoadFromCache: books.isNotEmpty
            ? () async => setState(() {
                  errorMessage = null;
                })
            : null,
      );
    }

    if (books.isEmpty) {
      return _EmptyStateWidget(onRefresh: () => _loadFirstPage());
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshFromServer,
              child: BooksTable(
                books: books,
                // Si tu BooksTable soporta callback:
                // onRowTap: _showBookDetails,
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
                    onPressed: _loadingMore ? null : _loadNextPage,
                    icon: _loadingMore
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_loadingMore ? 'Cargando...' : 'Ver más'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _filterTimer?.cancel();
    repository.endSession();
    super.dispose();
  }
}

// ---- Opciones de datos ----
class _CacheOptionsSheet extends StatelessWidget {
  final BookRepository repository;
  final Map<String, int> bookStats;

  const _CacheOptionsSheet({
    required this.repository,
    required this.bookStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Opciones de datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado actual:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Sesión activa: ${repository.isSessionActive ? "Sí" : "No"}'),
                Text('Libros cargados en pantalla: ${bookStats['totalBooks']}'),
                Text('Con consignación: ${bookStats['booksWithConsignment']}'),
                Text('Propios: ${bookStats['booksWithOwn']}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Actualizar desde servidor'),
            subtitle: const Text('Descargar todo de nuevo (si hay conexión)'),
            onTap: () => Navigator.pop(context, 'refresh'),
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Limpiar caché'),
            subtitle: const Text('Borrar datos locales'),
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

// ---- Widgets auxiliares (sin cambios de lógica) ----

class _FiltersRow extends StatelessWidget {
  final bool obrasConsignacion;
  final bool obrasPropias;
  final bool isLoading;
  final int filteredCount;
  final int totalCount;
  final Function(bool, bool) onFilterChanged;

  const _FiltersRow({
    required this.obrasConsignacion,
    required this.obrasPropias,
    required this.isLoading,
    required this.filteredCount,
    required this.totalCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CheckboxFilter(
          value: obrasConsignacion,
          label: "Consignación",
          isEnabled: !isLoading,
          onChanged: (value) => onFilterChanged(true, value ?? false),
        ),
        const SizedBox(width: 16),
        _CheckboxFilter(
          value: obrasPropias,
          label: "Propias",
          isEnabled: !isLoading,
          onChanged: (value) => onFilterChanged(false, value ?? false),
        ),
        const SizedBox(width: 16),
        if (!isLoading)
          Expanded(
            child: Text(
              '$filteredCount de $totalCount libros',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
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
                width: 20, height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: isEnabled ? onChanged : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isEnabled ? null : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final bool isFirstLoad;
  final bool sessionActive;

  const _LoadingWidget({
    required this.isFirstLoad,
    required this.sessionActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(height: 16),
            Text(isFirstLoad ? 'Cargando libros...' : 'Actualizando datos...', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              sessionActive
                  ? (isFirstLoad ? 'Esto puede tomar hasta 2 minutos' : 'Obteniendo datos actualizados')
                  : 'Primer uso',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (sessionActive && !isFirstLoad) ...[
              const SizedBox(height: 8),
              Text('Usando datos locales (offline OK)', style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
            ],
          ],
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
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
                  if (showCacheOption && onLoadFromCache != null)
                    ElevatedButton(
                      onPressed: onLoadFromCache,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Usar caché local'),
                    ),
                  OutlinedButton(onPressed: onClose, child: const Text('Cerrar')),
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
            const Text('No hay libros disponibles', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Cargar libros')),
          ],
        ),
      ),
    );
  }
}
