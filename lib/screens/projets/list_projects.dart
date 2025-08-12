import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/screens/main/components/header.dart'; // Corrected import path for Header
import 'package:admin/model/projet.dart'; // Corrected import path for Projet
import 'package:admin/services/project_service.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({Key? key}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late Future<List<Projet>> _projectsFuture;
  final ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _projectsFuture = _projectService.fetchProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = _projectService.fetchProjects();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showProjectDialog({Projet? project}) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: project?.titre);
    final _descriptionController = TextEditingController(text: project?.description);

    // For simplicity, hardcoding user IDs. In a real app, these would come from user selection.
    final int _usersIdClient = 1;
    final int _usersIdChefProjet = 2;
    final int _usersIdChefChantie = 3;

    await showDialog(
      context: context,
      builder: (context) {
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
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (project == null) {
                      // Add new project
                      final newProjet = Projet(
                        usersIdClient: _usersIdClient,
                        usersIdChefProjet: _usersIdChefProjet,
                        usersIdChefChantie: _usersIdChefChantie,
                        titre: _titreController.text,
                        description: _descriptionController.text,
                      );
                      await _projectService.addProject(newProjet);
                      _showSnackBar('Project added successfully!');
                    } else {
                      // Update existing project
                      final updatedProjet = Projet(
                        id: project.id,
                        usersIdClient: _usersIdClient, // Keep existing or update
                        usersIdChefProjet: _usersIdChefProjet, // Keep existing or update
                        usersIdChefChantie: _usersIdChefChantie, // Keep existing or update
                        titre: _titreController.text,
                        description: _descriptionController.text,
                      );
                      await _projectService.updateProject(updatedProjet);
                      _showSnackBar('Project updated successfully!');
                    }
                    _refreshProjects();
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackBar('Error: ${e.toString()}', isError: true);
                  }
                }
              },
              child: Text(project == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
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
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FutureBuilder<List<Projet>>(
                future: _projectsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Display message when no data is found
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'There is no data in database',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  } else {
                    final projets = snapshot.data!;
                    return SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: defaultPadding,
                        columns: const [
                          DataColumn(label: Text("Title")),
                          DataColumn(label: Text("Description")),
                          DataColumn(label: Text("Client ID")),
                          DataColumn(label: Text("Chef Projet ID")),
                          DataColumn(label: Text("Chef Chantier ID")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: projets.map((projet) {
                          return DataRow(cells: [
                            DataCell(Text(projet.titre)),
                            DataCell(Text(projet.description)),
                            DataCell(Text(projet.usersIdClient.toString())),
                            DataCell(Text(projet.usersIdChefProjet.toString())),
                            DataCell(Text(projet.usersIdChefChantie.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showProjectDialog(project: projet),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(projet.id!),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
