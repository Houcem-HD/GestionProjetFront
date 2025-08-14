// lib/model/user.dart
class User {
  final int? id;
  final int rolesId;
  final String nom;
  final String prenom;
  final String email;
  final String? password;
  final String? phone;
  final String? adresse;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  User({
    this.id,
    required this.rolesId,
    required this.nom,
    required this.prenom,
    required this.email,
    this.password,
    this.phone,
    this.adresse,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      rolesId: json['roles_id'] ?? 2,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'],
      adresse: json['adresse'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
  final data = {
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'phone': phone,
    'adresse': adresse,
    'status': status,
    'roles_id': rolesId,
  };

  if (password != null && password!.isNotEmpty) {
    data['password'] = password;
  }

  return data;
}

}
