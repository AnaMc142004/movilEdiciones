class Book {
  final String id;
  final String nombre;
  final String isbn;
  final String editorial;
  final int cantidadPropia;
  final int cantidadConsignacion;
  final int total;

  Book({
    required this.id,
    required this.nombre,
    required this.isbn,
    required this.editorial,
    required this.cantidadPropia,
    required this.cantidadConsignacion,
    required this.total,
  });


  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      isbn: map['isbn']?.toString() ?? '',
      editorial: map['editorial']?.toString() ?? '',
      cantidadPropia: _safeToInt(map['cantidadPropia']),
      cantidadConsignacion: _safeToInt(map['cantidadConsignacion']),
      total: _safeToInt(map['total']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'isbn': isbn,
      'editorial': editorial,
      'cantidadPropia': cantidadPropia,
      'cantidadConsignacion': cantidadConsignacion,
      'total': total,
    };
  }

  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  String toString() {
    return 'Book(id: $id, nombre: $nombre, editorial: $editorial, cantidadPropia: $cantidadPropia, cantidadConsignacion: $cantidadConsignacion, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
