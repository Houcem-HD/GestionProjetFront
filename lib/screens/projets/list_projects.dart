import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/screens/main/components/header.dart';
import 'package:admin/model/projet.dart';
import 'package:admin/services/project_services.dart';
import 'package:admin/model/user.dart';
import 'package:admin/services/user_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projectsFuture;
  late Future<List<User>> _usersFuture;
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  String _searchQuery = "";
  List<Project>? _cachedProjects;
  List<User>? _cachedUsers;

  String _sortColumn = '';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _projectService.fetchProjects();
    _usersFuture = _userService.fetchUsers();
  }

  String _getUserFullName(int? userId) {
    if (userId == null || _cachedUsers == null) return 'N/A';
    
    final user = _cachedUsers!.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        nom: 'Unknown', 
        prenom: 'User', 
        email: '',
        rolesId: 2, // Default role ID
        status: 'active', // Default status
      ),
    );
    
    return '${user.nom} ${user.prenom}';
  }

  void _sortProjects(List<Project> projects) {
    if (_sortColumn.isEmpty) return;

    projects.sort((a, b) {
      int comparison = 0;
      
      switch (_sortColumn) {
        case 'titre':
          comparison = a.titre.toLowerCase().compareTo(b.titre.toLowerCase());
          break;
        case 'description':
          comparison = a.description.toLowerCase().compareTo(b.description.toLowerCase());
          break;
        case 'client':
          final clientA = _getUserFullName(a.usersIdClient);
          final clientB = _getUserFullName(b.usersIdClient);
          comparison = clientA.toLowerCase().compareTo(clientB.toLowerCase());
          break;
        case 'chef_projet':
          final chefA = _getUserFullName(a.usersIdChefProjet);
          final chefB = _getUserFullName(b.usersIdChefProjet);
          comparison = chefA.toLowerCase().compareTo(chefB.toLowerCase());
          break;
        case 'chef_chantier':
          final chantierA = _getUserFullName(a.usersIdChefChantie);
          final chantierB = _getUserFullName(b.usersIdChefChantie);
          comparison = chantierA.toLowerCase().compareTo(chantierB.toLowerCase());
          break;
        case 'status':
          comparison = a.status.toLowerCase().compareTo(b.status.toLowerCase());
          break;
        case 'created':
          if (a.createdAt != null && b.createdAt != null) {
            comparison = a.createdAt!.compareTo(b.createdAt!);
          } else if (a.createdAt != null) {
            comparison = 1;
          } else if (b.createdAt != null) {
            comparison = -1;
          }
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  Widget _buildSortableColumn(String label, String column) {
    return InkWell(
      onTap: () => _onSort(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(width: 4),
          if (_sortColumn == column)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Theme.of(context).primaryColor,
            )
          else
            Icon(
              Icons.unfold_more,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = _projectService.fetchProjects();
      _cachedProjects = null; // Clear cache to force refresh
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = "";
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(project.titre),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Description', project.description),
                _buildDetailRow('Client', _getUserFullName(project.usersIdClient)),
                _buildDetailRow('Chef de Projet', _getUserFullName(project.usersIdChefProjet)),
                _buildDetailRow('Chef de Chantier', _getUserFullName(project.usersIdChefChantie)),
                _buildDetailRow('Status', project.status),
                if (project.createdAt != null)
                  _buildDetailRow('Created At', project.createdAt.toString()),
                if (project.updatedAt != null)
                  _buildDetailRow('Updated At', project.updatedAt.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showProjectDialog(project: project);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _showProjectDialog({Project? project}) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: project?.titre ?? '');
    final _descriptionController = TextEditingController(text: project?.description ?? '');
    int? _selectedClientId = project?.usersIdClient;
    int? _selectedChefProjetId = project?.usersIdChefProjet;
    int? _selectedChefChantierId = project?.usersIdChefChantie;
    String _selectedStatus = project?.status ?? 'valide';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(project == null ? 'Add New Project' : 'Edit Project'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(labelText: 'Project Title'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a project title'
                        : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'valide', child: Text('Valide')),
                          DropdownMenuItem(value: 'invalide', child: Text('Invalide')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a status';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<User>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      
                      final users = snapshot.data!;
                      
                      return Column(
                        children: [
                          StatefulBuilder(
                            builder: (context, setState) {
                              return DropdownButtonFormField<int>(
                                value: _selectedClientId,
                                decoration: const InputDecoration(labelText: 'Client'),
                                items: users.map((User user) {
                                  return DropdownMenuItem<int>(
                                    value: user.id,
                                    child: Text('${user.nom} ${user.prenom}'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedClientId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a client';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return DropdownButtonFormField<int>(
                                value: _selectedChefProjetId,
                                decoration: const InputDecoration(labelText: 'Chef de Projet'),
                                items: users.map((User user) {
                                  return DropdownMenuItem<int>(
                                    value: user.id,
                                    child: Text('${user.nom} ${user.prenom}'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedChefProjetId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a chef de projet';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return DropdownButtonFormField<int>(
                                value: _selectedChefChantierId,
                                decoration: const InputDecoration(labelText: 'Chef de Chantier'),
                                items: users.map((User user) {
                                  return DropdownMenuItem<int>(
                                    value: user.id,
                                    child: Text('${user.nom} ${user.prenom}'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedChefChantierId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a chef de chantier';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (project == null) {
                      final newProject = Project(
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        usersIdClient: _selectedClientId!,
                        usersIdChefProjet: _selectedChefProjetId!,
                        usersIdChefChantie: _selectedChefChantierId!,
                        status: _selectedStatus,
                      );
                      await _projectService.addProject(newProject);
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        _showSnackBar('Project added successfully!');
                        _refreshProjects();
                      }
                    } else {
                      final updatedProject = Project(
                        id: project.id,
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        usersIdClient: _selectedClientId!,
                        usersIdChefProjet: _selectedChefProjetId!,
                        usersIdChefChantie: _selectedChefChantierId!,
                        status: _selectedStatus,
                        createdAt: project.createdAt,
                        updatedAt: project.updatedAt,
                      );
                      await _projectService.updateProject(updatedProject);
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        _showSnackBar('Project updated successfully!');
                        _refreshProjects();
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      String errorMessage = 'Error: ${e.toString()}';
                      _showSnackBar(errorMessage, isError: true);
                    }
                  }
                }
              },
              child: Text(project == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );

    _titreController.dispose();
    _descriptionController.dispose();
  }

  Future<void> _validateProject(int projectId) async {
    try {
      final updatedProject = await _projectService.validateProject(projectId);
      _showSnackBar('Project validated successfully!');
      
      if (_cachedProjects != null) {
        setState(() {
          final index = _cachedProjects!.indexWhere((project) => project.id == projectId);
          if (index != -1) {
            _cachedProjects![index] = updatedProject;
          }
        });
      } else {
        _refreshProjects();
      }
    } catch (e) {
      _showSnackBar('Error validating project: ${e.toString()}', isError: true);
    }
  }

  Future<void> _invalidateProject(int projectId) async {
    try {
      final updatedProject = await _projectService.invalidateProject(projectId);
      _showSnackBar('Project invalidated successfully!');
      
      if (_cachedProjects != null) {
        setState(() {
          final index = _cachedProjects!.indexWhere((project) => project.id == projectId);
          if (index != -1) {
            _cachedProjects![index] = updatedProject;
          }
        });
      } else {
        _refreshProjects();
      }
    } catch (e) {
      _showSnackBar('Error invalidating project: ${e.toString()}', isError: true);
    }
  }

  Future<void> _confirmInvalidate(int projectId, String projectName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Invalidate'),
          content: Text('Are you sure you want to invalidate $projectName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Invalidate'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _invalidateProject(projectId);
    }
  }

  Future<void> _confirmValidate(int projectId, String projectName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Validate'),
          content: Text('Are you sure you want to validate $projectName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Validate'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await _projectService.validateProject(projectId);
        _showSnackBar('Project validated successfully!');
        _refreshProjects();
      } catch (e) {
        _showSnackBar('Error validating project: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await _projectService.deleteProject(id);
        _showSnackBar('Project deleted successfully!');
        _refreshProjects();
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                Header(
                  onSearchChanged: _handleSearch,
                  onSearchClear: _clearSearch,
                ),
                const SizedBox(height: defaultPadding),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Projects",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding,
                        ),
                      ),
                      onPressed: () => _showProjectDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Project"),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity, // Force full width
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([_projectsFuture, _usersFuture]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  }

                  final projects = snapshot.data![0] as List<Project>;
                  final users = snapshot.data![1] as List<User>;

                  if (_cachedProjects == null) {
                    _cachedProjects = List.from(projects);
                  }
                  if (_cachedUsers == null) {
                    _cachedUsers = List.from(users);
                  }

                  if (projects.isEmpty) {
                    return const Center(child: Text('There is no data in database'));
                  }

                  final filteredProjects = _cachedProjects!.where((project) {
                    final searchLower = _searchQuery.toLowerCase();
                    return project.titre.toLowerCase().contains(searchLower) ||
                        project.description.toLowerCase().contains(searchLower) ||
                        _getUserFullName(project.usersIdClient).toLowerCase().contains(searchLower) ||
                        _getUserFullName(project.usersIdChefProjet).toLowerCase().contains(searchLower) ||
                        _getUserFullName(project.usersIdChefChantie).toLowerCase().contains(searchLower) ||
                        project.status.toLowerCase().contains(searchLower);
                  }).toList();

                  _sortProjects(filteredProjects);

                  if (filteredProjects.isEmpty) {
                    return const Center(child: Text("No matching results"));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 800;
                      bool isTablet = constraints.maxWidth >= 800 && constraints.maxWidth < 1200;

                      if (isMobile) {
                        return SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: defaultPadding,
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(label: _buildSortableColumn("Title", "titre")),
                                DataColumn(label: _buildSortableColumn("Description", "description")),
                                DataColumn(label: _buildSortableColumn("Client", "client")),
                                DataColumn(label: _buildSortableColumn("Chef Projet", "chef_projet")),
                                DataColumn(label: _buildSortableColumn("Status", "status")),
                                DataColumn(
                                  label: Text(
                                    "Actions",
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                              ],
                              rows: filteredProjects.map((project) {
                                final rowColor = project.status == 'valide' 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1);
                                return DataRow(
                                  color: MaterialStateProperty.all(rowColor),
                                  onSelectChanged: (_) => _showProjectDetails(project),
                                  cells: [
                                    DataCell(Text(project.titre)),
                                    DataCell(
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          project.description.length > 50 
                                              ? '${project.description.substring(0, 50)}...'
                                              : project.description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(_getUserFullName(project.usersIdClient))),
                                    DataCell(Text(_getUserFullName(project.usersIdChefProjet))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: project.status == 'valide' ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          project.status,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showProjectDialog(project: project),
                                          ),
                                          if (project.status == 'invalide')
                                            IconButton(
                                              icon: const Icon(Icons.check_circle, color: Colors.green),
                                              onPressed: () => _validateProject(project.id!),
                                              tooltip: 'Validate Project',
                                            )
                                          else
                                            IconButton(
                                              icon: const Icon(Icons.cancel, color: Colors.orange),
                                              onPressed: () => _confirmInvalidate(project.id!, project.titre),
                                              tooltip: 'Invalidate Project',
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDelete(project.id!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: isTablet ? defaultPadding * 0.8 : defaultPadding * 2,
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: _buildSortableColumn("Title", "titre")),
                              DataColumn(label: _buildSortableColumn("Description", "description")),
                              DataColumn(label: _buildSortableColumn("Client", "client")),
                              DataColumn(label: _buildSortableColumn(isTablet ? "Chef P." : "Chef Projet", "chef_projet")),
                              DataColumn(label: _buildSortableColumn(isTablet ? "Chef C." : "Chef Chantier", "chef_chantier")),
                              DataColumn(label: _buildSortableColumn("Status", "status")),
                              DataColumn(
                                label: Text(
                                  "Actions",
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                ),
                              ),
                            ],
                            rows: filteredProjects.map((project) {
                              final rowColor = project.status == 'valide' 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1);
                              return DataRow(
                                color: MaterialStateProperty.all(rowColor),
                                onSelectChanged: (_) => _showProjectDetails(project),
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: isTablet ? 120 : double.infinity,
                                      child: Text(
                                        project.titre,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isTablet ? 140 : 200,
                                      child: Text(
                                        project.description.length > (isTablet ? 60 : 80) 
                                            ? '${project.description.substring(0, isTablet ? 60 : 80)}...'
                                            : project.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: isTablet ? 2 : 3,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isTablet ? 100 : double.infinity,
                                      child: Text(
                                        _getUserFullName(project.usersIdClient),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isTablet ? 100 : double.infinity,
                                      child: Text(
                                        _getUserFullName(project.usersIdChefProjet),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isTablet ? 100 : double.infinity,
                                      child: Text(
                                        _getUserFullName(project.usersIdChefChantie),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: project.status == 'valide' ? Colors.green : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        project.status,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue, size: isTablet ? 20 : 24),
                                          onPressed: () => _showProjectDialog(project: project),
                                        ),
                                        if (project.status == 'invalide')
                                          IconButton(
                                            icon: Icon(Icons.check_circle, color: Colors.green, size: isTablet ? 20 : 24),
                                            onPressed: () => _validateProject(project.id!),
                                            tooltip: 'Validate Project',
                                          )
                                        else
                                          IconButton(
                                            icon: Icon(Icons.cancel, color: Colors.orange, size: isTablet ? 20 : 24),
                                            onPressed: () => _confirmInvalidate(project.id!, project.titre),
                                            tooltip: 'Invalidate Project',
                                          ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red, size: isTablet ? 20 : 24),
                                          onPressed: () => _confirmDelete(project.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
