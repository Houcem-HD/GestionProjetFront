import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/screens/main/components/header.dart';
import 'package:admin/model/user.dart';
import 'package:admin/services/user_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    if (!mounted) return; // Prevent accessing disposed context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showUserDialog({User? user}) async {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController(text: user?.nom ?? '');
    final _prenomController = TextEditingController(text: user?.prenom ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');
    final _phoneController = TextEditingController(text: user?.phone ?? '');
    final _adresseController = TextEditingController(text: user?.adresse ?? '');
    final _statusController =
        TextEditingController(text: user?.status ?? 'active');
    final _rolesIdController =
        TextEditingController(text: (user?.rolesId ?? 2).toString());
    final _passwordController =
        TextEditingController(text: user?.password ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
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
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a nom'
                        : null,
                  ),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(labelText: 'Prenom'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a prenom'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter an email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
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
                      if (user == null && (value == null || value.isEmpty)) {
                        return 'Please enter a password';
                      }
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a phone number'
                        : null,
                  ),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter an adresse'
                        : null,
                  ),
                  TextFormField(
                    controller: _statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter a status';
                      if (!['active', 'inactive']
                          .contains(value.toLowerCase())) {
                        return 'Status must be active or inactive';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _rolesIdController,
                    decoration: const InputDecoration(labelText: 'Role ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter a role ID';
                      if (int.tryParse(value) == null)
                        return 'Please enter a valid number';
                      return null;
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
                    if (user == null) {
                      final newUser = User(
                        id: null,
                        rolesId: int.parse(_rolesIdController.text),
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _statusController.text,
                      );
                      print('Request body: ${json.encode(newUser.toJson())}');
                      await _userService.addUser(newUser);
                      if (mounted) {
                        _showSnackBar('User added successfully!');
                        Navigator.pop(dialogContext);
                        _refreshUsers();
                      }
                    } else {
                      final updatedUser = User(
                        id: user.id,
                        rolesId: int.parse(_rolesIdController.text),
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text.isNotEmpty &&
                                _passwordController.text != user.password
                            ? _passwordController.text
                            : user.password,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _statusController.text,
                        createdAt: user.createdAt,
                        updatedAt: user.updatedAt,
                        deletedAt: user.deletedAt,
                      );
                      await _userService.updateUser(updatedUser);
                      if (mounted) {
                        _showSnackBar('User updated successfully!');
                        Navigator.pop(dialogContext);
                        _refreshUsers();
                      }
                    }
                  } catch (e) {
                    print('Error: $e');
                    if (mounted) {
                      String errorMessage = 'Error: ${e.toString()}';
                      if (e.toString().contains('unique')) {
                        errorMessage = 'Email already exists';
                      } else if (e.toString().contains('exists')) {
                        errorMessage = 'Invalid role ID';
                      } else if (e.toString().contains('timeout')) {
                        errorMessage = 'Server took too long to respond';
                      }
                      _showSnackBar(errorMessage, isError: true);
                    }
                  }
                }
              },
              child: Text(user == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );

    // Dispose controllers
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    _statusController.dispose();
    _rolesIdController.dispose();
    _passwordController.dispose();
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
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
        await _userService.deleteUser(id);
        _showSnackBar('User deleted successfully!');
        _refreshUsers();
      } catch (e) {
        print('Error: $e');
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'There is no data in database',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    } else {
                      final users = snapshot.data!;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          bool isMobile = constraints.maxWidth < 600;

                          if (isMobile) {
                            // 📱 Mobile → Horizontal scroll
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                                    DataCell(Text(user.phone ?? '')),
                                    DataCell(Text(user.adresse ?? '')),
                                    DataCell(Text(user.status)),
                                    DataCell(Text(user.rolesId.toString())),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () =>
                                              _showUserDialog(user: user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDelete(user.id!),
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            );
                          } else {
                            // 💻 Desktop → Fill available width
                            double columnWidth = constraints.maxWidth / 8;
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 0,
                                columns: const [
                                  DataColumn(label: Text("Nom")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Phone")),
                                  DataColumn(label: Text("Status")),
                                  DataColumn(label: Text("Role ID")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                rows: users.map((user) {
                                  return DataRow(cells: [
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text("${user.nom} ${user.prenom}"))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(user.email))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(user.phone ?? ''))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(user.status))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(user.rolesId.toString()))),
                                    DataCell(SizedBox(
                                      width: columnWidth,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _showUserDialog(user: user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmDelete(user.id!),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
