import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../models/book_model.dart';
import '../services/book_db.dart';

class BookService {
  final String baseUrl = 'https://backediciones.com/api';

  static const int maxRetries = 3;
  static const Duration baseTimeout = Duration(seconds: 60);
  static const String tableName = 'books';
  static const String cacheTableName = 'cache_metadata';

  bool _isSessionActive = false;

  void startSession() => _isSessionActive = true;
  void endSession() => _isSessionActive = false;
  bool get isSessionActive => _isSessionActive;

  Future<void> ensureLocalData() async {
    final count = await DbService.instance.getTableSize(tableName);
    if (count > 0) {
      return;
    }
    await _fetchAllFromAPIAndCache();
  }


  Future<void> refreshAllFromAPI() async {
    await _clearCacheInternal();
    await _fetchAllFromAPIAndCache();
  }

  Future<BookStats> getBookStats() async {
    final Database db = await DbService.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalBooks,
        SUM(cantidadConsignacion) as totalConsignment,
        SUM(cantidadPropia) as totalOwn,
        COUNT(CASE WHEN cantidadConsignacion > 0 THEN 1 END) as booksWithConsignment,
        COUNT(CASE WHEN cantidadPropia > 0 THEN 1 END) as booksWithOwn
      FROM $tableName
    ''');

    final row = result.first;
    return BookStats(
      totalBooks: (row['totalBooks'] as int?) ?? 0,
      totalConsignment: (row['totalConsignment'] as int?) ?? 0,
      totalOwn: (row['totalOwn'] as int?) ?? 0,
      booksWithConsignment: (row['booksWithConsignment'] as int?) ?? 0,
      booksWithOwn: (row['booksWithOwn'] as int?) ?? 0,
    );
  }
  Future<PageResult<Book>> queryBooksPageFromDB({
    required int page,
    required int pageSize,
    bool? hasConsignment,
    bool? hasOwn,
    String? searchQuery,
  }) async {
    final Database db = await DbService.instance.database;

    // WHERE dinámico
    final whereParts = <String>[];
    final whereArgs = <Object?>[];

    if (hasConsignment == true) {
      whereParts.add('cantidadConsignacion > 0');
    }
    if (hasOwn == true) {
      whereParts.add('cantidadPropia > 0');
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.toLowerCase()}%';
      whereParts.add(
        '(LOWER(nombre) LIKE ? OR LOWER(isbn) LIKE ? OR LOWER(editorial) LIKE ?)',
      );
      whereArgs.addAll([q, q, q]);
    }

    final where = whereParts.isEmpty ? null : whereParts.join(' AND ');
    final offset = (page - 1) * pageSize;

    final rows = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nombre COLLATE NOCASE ASC',
      limit: pageSize,
      offset: offset,
    );

    final statsQuery = StringBuffer('''
      SELECT 
        COUNT(*) as totalFiltered,
        SUM(cantidadConsignacion) as filteredConsignment,
        SUM(cantidadPropia) as filteredOwn,
        COUNT(CASE WHEN cantidadConsignacion > 0 THEN 1 END) as filteredBooksWithConsignment,
        COUNT(CASE WHEN cantidadPropia > 0 THEN 1 END) as filteredBooksWithOwn
      FROM $tableName
    ''');

    if (where != null) statsQuery.write(' WHERE $where');

    final statsRows = await db.rawQuery(statsQuery.toString(), whereArgs);
    final statsRow = statsRows.first;

    final totalFiltered = (statsRow['totalFiltered'] as int?) ?? 0;
    final filteredStats = FilteredBookStats(
      totalFiltered: totalFiltered,
      filteredConsignment: (statsRow['filteredConsignment'] as int?) ?? 0,
      filteredOwn: (statsRow['filteredOwn'] as int?) ?? 0,
      filteredBooksWithConsignment:
          (statsRow['filteredBooksWithConsignment'] as int?) ?? 0,
      filteredBooksWithOwn: (statsRow['filteredBooksWithOwn'] as int?) ?? 0,
    );

    final items = rows.map((m) => Book.fromMap(m)).toList(growable: false);
    final hasMore = offset + items.length < totalFiltered;

    return PageResult<Book>(
      items: items,
      hasMore: hasMore,
      totalCount: totalFiltered,
      filteredStats: filteredStats,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  Future<void> clearCache() async {
    await _clearCacheInternal();
  }

  Future<void> _clearCacheInternal() async {
    await DbService.instance.clearTable(tableName);
    await DbService.instance.delete(
      cacheTableName,
      where: 'key = ?',
      whereArgs: ['books_cache'],
    );
  }

  Future<void> _fetchAllFromAPIAndCache() async {
    final String raw = await _requestBooksRawWithRetry();
    final List<Book> books = await compute(
      _parseBooksFromJsonIsolateService,
      raw,
    );
    await _saveBooksToCache(books);
  }

  Future<String> _requestBooksRawWithRetry() async {
    int retries = 0;

    while (retries < maxRetries) {
      try {
        final url = Uri.parse('$baseUrl/books/all');
        final client = http.Client();
        try {
          final response = await client
              .get(
                url,
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'User-Agent': 'EdicionesHispanicas/1.0',
                  'Connection': 'keep-alive',
                },
              )
              .timeout(
                Duration(seconds: baseTimeout.inSeconds + (retries * 15)),
              );

          if (response.statusCode == 200) {
            final raw = utf8.decode(response.bodyBytes);
            if (raw.isEmpty) {
              throw const FormatException('Respuesta vacía del servidor');
            }
            return raw;
          } else if (response.statusCode >= 500) {
            throw HttpException('Error del servidor: ${response.statusCode}');
          } else {
            throw Exception('Error del cliente: ${response.statusCode}');
          }
        } finally {
          client.close();
        }
      } on TimeoutException catch (e) {
        retries++;
        if (retries >= maxRetries) {
          throw Exception(
            'La conexión está tardando demasiado. Verifica tu internet e inténtalo de nuevo.',
          );
        }
        await Future.delayed(Duration(seconds: 2 * retries));
      } on SocketException {
        throw Exception(
          'Sin conexión a internet. Verifica tu conexión y vuelve a intentar.',
        );
      } on HttpException catch (e) {
        retries++;
        if (retries >= maxRetries) {
          throw Exception('Error del servidor. Por favor inténtalo más tarde.');
        }
        await Future.delayed(Duration(seconds: 2 * retries));
      } catch (e) {
        throw Exception('Error inesperado al cargar libros: ${e.toString()}');
      }
    }

    throw Exception(
      'No se pudo cargar los libros después de $maxRetries intentos',
    );
  }

  Future<void> _saveBooksToCache(List<Book> books) async {
    await DbService.instance.clearTable(tableName);

    const int chunkSize = 200;
    for (int i = 0; i < books.length; i += chunkSize) {
      final end = (i + chunkSize < books.length) ? i + chunkSize : books.length;
      final slice = books.sublist(i, end);
      for (final b in slice) {
        await DbService.instance.insert(tableName, b.toMap());
      }
      await Future.delayed(const Duration(milliseconds: 1));
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await DbService.instance.delete(
      cacheTableName,
      where: 'key = ?',
      whereArgs: ['books_cache'],
    );
    await DbService.instance.insert(cacheTableName, {
      'key': 'books_cache',
      'last_update': now,
      'created_at': now,
    });
  }
}

class PageResult<T> {
  final List<T> items;
  final bool hasMore;
  final int totalCount;
  final FilteredBookStats? filteredStats;
  final int currentPage;
  final int pageSize;

  PageResult({
    required this.items,
    required this.hasMore,
    required this.totalCount,
    this.filteredStats,
    required this.currentPage,
    required this.pageSize,
  });
  String get pageInfo {
    final start = ((currentPage - 1) * pageSize) + 1;
    final end = start + items.length - 1;
    return "Mostrando $start-$end de $totalCount";
  }

  int get totalPages => (totalCount / pageSize).ceil();
}

class BookStats {
  final int totalBooks;
  final int totalConsignment;
  final int totalOwn;
  final int booksWithConsignment;
  final int booksWithOwn;

  BookStats({
    required this.totalBooks,
    required this.totalConsignment,
    required this.totalOwn,
    required this.booksWithConsignment,
    required this.booksWithOwn,
  });
}

class FilteredBookStats {
  final int totalFiltered;
  final int filteredConsignment;
  final int filteredOwn;
  final int filteredBooksWithConsignment;
  final int filteredBooksWithOwn;

  FilteredBookStats({
    required this.totalFiltered,
    required this.filteredConsignment,
    required this.filteredOwn,
    required this.filteredBooksWithConsignment,
    required this.filteredBooksWithOwn,
  });
}

List<Book> _parseBooksFromJsonIsolateService(String body) {
  final dynamic decoded = jsonDecode(body);

  if (decoded is List) {
    return decoded
        .map<Book>((e) => _bookFromDynamicIsolate(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  if (decoded is Map<String, dynamic>) {
    final data = decoded['data'];
    if (data is List) {
      return data
          .map<Book>((e) => _bookFromDynamicIsolate(e as Map<String, dynamic>))
          .toList(growable: false);
    }
  }

  throw const FormatException('JSON de libros con formato no soportado');
}

Book _bookFromDynamicIsolate(Map<String, dynamic> item) {
  return Book(
    id: _safeToStringIsolate(item['id_autoincremental'] ?? item['id'] ?? ''),
    nombre: _safeToStringIsolate(item['name'] ?? 'Sin nombre'),
    isbn: _safeToStringIsolate(item['isbn'] ?? ''),
    editorial: _safeToStringIsolate(
      item['publishing.provider.corporate_name'] ??
          item['editorial'] ??
          'Sin editorial',
    ),
    cantidadPropia: _safeToIntIsolate(item['own_quantity_total'] ?? 0),
    cantidadConsignacion: _safeToIntIsolate(
      item['consignment_quantity_total'] ?? 0,
    ),
    total: _safeToIntIsolate(item['cost'] ?? item['total'] ?? 0),
  );
}

String _safeToStringIsolate(dynamic value) => value?.toString() ?? '';
int _safeToIntIsolate(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

