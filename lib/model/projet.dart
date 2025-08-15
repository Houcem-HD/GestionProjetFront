class Project {
  final int? id;
  final int usersIdClient;
  final int usersIdChefProjet;
  final int usersIdChefChantie;
  final String titre;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    this.id,
    required this.usersIdClient,
    required this.usersIdChefProjet,
    required this.usersIdChefChantie,
    required this.titre,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      usersIdClient: json['users_id_client'],
      usersIdChefProjet: json['users_id_chef_projet'],
      usersIdChefChantie: json['users_id_chef_chantie'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'valide',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'users_id_client': usersIdClient,
      'users_id_chef_projet': usersIdChefProjet,
      'users_id_chef_chantie': usersIdChefChantie,
      'titre': titre,
      'description': description,
      'status': status,
    };
  }
}
