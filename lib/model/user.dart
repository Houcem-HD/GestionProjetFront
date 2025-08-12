class User {
  final int? id;
  final int rolesId;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String phone;
  final String adresse;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.rolesId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.phone,
    required this.adresse,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      rolesId: json['roles_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      adresse: json['adresse'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roles_id': rolesId,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'phone': phone,
      'adresse': adresse,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
