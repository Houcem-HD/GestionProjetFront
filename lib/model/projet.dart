class Projet {
  final int? id;
  final int usersIdClient;
  final int usersIdChefProjet;
  final int usersIdChefChantie;
  final String titre;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Projet({
    this.id,
    required this.usersIdClient,
    required this.usersIdChefProjet,
    required this.usersIdChefChantie,
    required this.titre,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      id: json['id'],
      usersIdClient: json['users_id_client'],
      usersIdChefProjet: json['users_id_chef_projet'],
      usersIdChefChantie: json['users_id_chef_chantie'],
      titre: json['titre'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users_id_client': usersIdClient,
      'users_id_chef_projet': usersIdChefProjet,
      'users_id_chef_chantie': usersIdChefChantie,
      'titre': titre,
      'description': description,
      // 'created_at': createdAt?.toIso8601String(), // Usually handled by backend
      // 'updated_at': updatedAt?.toIso8601String(), // Usually handled by backend
    };
  }
}
