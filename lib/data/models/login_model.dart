// lib/data/models/login_model.dart
import 'dart:convert';

class Warehouse {
  final String id;
  final String name;
  final String address;
  final String email;
  final String city;
  final String? imageUrl;
  final int capacity;
  final int ownAmount;
  final int consignmentAmount;
  final int total;
  final String departament;
  final int numberInvoice;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.city,
    this.imageUrl,
    required this.capacity,
    required this.ownAmount,
    required this.consignmentAmount,
    required this.total,
    required this.departament,
    required this.numberInvoice,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        email: json['email'],
        city: json['city'],
        imageUrl: json['imageUrl'],
        capacity: json['capacity'],
        ownAmount: json['own_amount'],
        consignmentAmount: json['consignment_amount'],
        total: json['total'],
        departament: json['departament'],
        numberInvoice: json['number_invoice'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'email': email,
        'city': city,
        'imageUrl': imageUrl,
        'capacity': capacity,
        'own_amount': ownAmount,
        'consignment_amount': consignmentAmount,
        'total': total,
        'departament': departament,
        'number_invoice': numberInvoice,
      };
}

class UserModel {
  final String id;
  final String name;
  final String lastname;
  final String document;
  final String email;
  final String role;
  final String charge;
  final bool blocked;
  final String authStrategy;
  final Warehouse warehouse;

  UserModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.document,
    required this.email,
    required this.role,
    required this.charge,
    required this.blocked,
    required this.authStrategy,
    required this.warehouse,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        lastname: json['lastname'],
        document: json['document'],
        email: json['email'],
        role: json['role'],
        charge: json['charge'],
        blocked: json['blocked'],
        authStrategy: json['authStrategy'],
        warehouse: Warehouse.fromJson(json['warehouse']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastname': lastname,
        'document': document,
        'email': email,
        'role': role,
        'charge': charge,
        'blocked': blocked,
        'authStrategy': authStrategy,
        'warehouse': warehouse.toJson(),
      };
}

class LoginResponse {
  final String accessToken;
  final UserModel user;

  LoginResponse({required this.accessToken, required this.user});

  // Mantengo "accesToken" como tu backend actual.
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accesToken'],
        user: UserModel.fromJson(json['user']),
      );

  Map<String, dynamic> toJson() => {
        // Si tu backend usa "accessToken", cambia la clave en estas 2 líneas.
        'accesToken': accessToken,
        'user': user.toJson(),
      };

  @override
  String toString() => jsonEncode(toJson());
}
