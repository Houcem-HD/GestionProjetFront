import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/screens/main/components/header.dart';
import 'package:admin/model/user.dart';
import 'package:admin/services/user_services.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.fetchUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.fetchUsers();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color.fromARGB(255, 255, 255, 255) : Colors.green,
      ),
    );
  }

  Future<void> _showUserDialog({User? user}) async {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController(text: user?.nom);
    final _prenomController = TextEditingController(text: user?.prenom);
    final _emailController = TextEditingController(text: user?.email);
    final _passwordController = TextEditingController(text: user?.password);
    final _phoneController = TextEditingController(text: user?.phone);
    final _adresseController = TextEditingController(text: user?.adresse);
    final _statusController = TextEditingController(text: user?.status);
    final _rolesIdController = TextEditingController(text: user?.rolesId.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Add New User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(labelText: 'Prenom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a prenom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an adresse';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a status';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _rolesIdController,
                    decoration: const InputDecoration(labelText: 'Role ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a role ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                    if (user == null) {
                      // Add new user
                      final newUser = User(
                        rolesId: int.parse(_rolesIdController.text),
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _statusController.text,
                      );
                      await _userService.addUser(newUser);
                      _showSnackBar('User added successfully!');
                    } else {
                      // Update existing user
                      final updatedUser = User(
                        id: user.id,
                        rolesId: int.parse(_rolesIdController.text),
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _statusController.text,
                        createdAt: user.createdAt,
                        updatedAt: user.updatedAt,
                      );
                      await _userService.updateUser(updatedUser);
                      _showSnackBar('User updated successfully!');
                    }
                    _refreshUsers();
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackBar('Error: ${e.toString()}', isError: true);
                  }
                }
              },
              child: Text(user == null ? 'Add' : 'Save'),
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
          content: const Text('Are you sure you want to delete this user?'),
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
        await _userService.deleteUser(id);
        _showSnackBar('User deleted successfully!');
        _refreshUsers();
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
                  "Users",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical: defaultPadding,
                    ),
                  ),
                  onPressed: () => _showUserDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Add New User"),
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
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    final users = snapshot.data!;
                    return SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: defaultPadding,
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("Prenom")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Adresse")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Role ID")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: users.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user.nom)),
                            DataCell(Text(user.prenom)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.phone)),
                            DataCell(Text(user.adresse)),
                            DataCell(Text(user.status)),
                            DataCell(Text(user.rolesId.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showUserDialog(user: user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(user.id!),
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