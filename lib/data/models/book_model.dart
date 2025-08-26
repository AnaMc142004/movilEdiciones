class Book {
  final String id; // nuevo
  final String nombre;
  final String isbn; // nuevo
  final String editorial; // nuevo
  final int cantidadPropia;
  final int cantidadConsignacion;
  final int total; // nuevo, puede ser calculado o recibido del API

  Book({
    required this.id,
    required this.nombre,
    required this.isbn,
    required this.editorial,
    required this.cantidadPropia,
    required this.cantidadConsignacion,
    required this.total,
  });

  // Constructor desde JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '', // convierte a string si viene como int
      nombre: json['name'] ?? 'Sin nombre',
      isbn: json['isbn'] ?? 'Sin ISBN',
      editorial: json['editorial'] ?? 'Sin editorial',
      cantidadPropia: json['own_quantity_total'] ?? 0,
      cantidadConsignacion: json['consignment_quantity_total'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nombre,
      'isbn': isbn,
      'editorial': editorial,
      'own_quantity_total': cantidadPropia,
      'consignment_quantity_total': cantidadConsignacion,
      'total': total,
    };
  }
}
