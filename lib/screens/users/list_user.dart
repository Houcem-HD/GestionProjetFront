import 'package:admin/model/role.dart';
import 'package:admin/services/role_services.dart';
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

  late Future<List<Role>> _rolesFuture;
  final RoleService _rolesService = RoleService();

  String _searchQuery = "";
  List<User>? _cachedUsers;

  String _sortColumn = '';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.fetchUsers();
    _rolesFuture = _rolesService.fetchRoles();
  }

  void _sortUsers(List<User> users, Map<int, String> roleMap) {
    if (_sortColumn.isEmpty) return;

    users.sort((a, b) {
      int comparison = 0;
      
      switch (_sortColumn) {
        case 'name':
          comparison = '${a.nom} ${a.prenom}'.toLowerCase().compareTo('${b.nom} ${b.prenom}'.toLowerCase());
          break;
        case 'email':
          comparison = a.email.toLowerCase().compareTo(b.email.toLowerCase());
          break;
        case 'phone':
          comparison = (a.phone ?? '').compareTo(b.phone ?? '');
          break;
        case 'role':
          final roleA = roleMap[a.rolesId] ?? '';
          final roleB = roleMap[b.rolesId] ?? '';
          comparison = roleA.toLowerCase().compareTo(roleB.toLowerCase());
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

  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.fetchUsers();
      _rolesFuture = _rolesService.fetchRoles();
      _cachedUsers = null; // Clear cache to force refresh
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

  Future<void> _activateUser(int userId) async {
    try {
      final updatedUser = await _userService.activateUser(userId);
      _showSnackBar('User activated successfully!');
      
      if (_cachedUsers != null) {
        setState(() {
          final index = _cachedUsers!.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _cachedUsers![index] = updatedUser;
          }
        });
      } else {
        _refreshUsers();
      }
    } catch (e) {
      _showSnackBar('Error activating user: ${e.toString()}', isError: true);
    }
  }

  Future<void> _suspendUser(int userId) async {
    try {
      final updatedUser = await _userService.suspendUser(userId);
      _showSnackBar('User suspended successfully!');
      
      if (_cachedUsers != null) {
        setState(() {
          final index = _cachedUsers!.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _cachedUsers![index] = updatedUser;
          }
        });
      } else {
        _refreshUsers();
      }
    } catch (e) {
      _showSnackBar('Error suspending user: ${e.toString()}', isError: true);
    }
  }

  void _showUserDetails(User user, String roleName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${user.nom} ${user.prenom}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Phone', user.phone ?? 'N/A'),
                _buildDetailRow('Address', user.adresse ?? 'N/A'),
                _buildDetailRow('Role', roleName),
                _buildDetailRow('Status', user.status),
                if (user.createdAt != null)
                  _buildDetailRow('Created At', user.createdAt.toString()),
                if (user.updatedAt != null)
                  _buildDetailRow('Updated At', user.updatedAt.toString()),
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
                _showUserDialog(user: user);
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
            width: 80,
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

  Future<void> _showUserDialog({User? user}) async {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController(text: user?.nom ?? '');
    final _prenomController = TextEditingController(text: user?.prenom ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');
    final _phoneController = TextEditingController(text: user?.phone ?? '');
    final _adresseController = TextEditingController(text: user?.adresse ?? '');
    String? _selectedStatus = user?.status ?? 'active';
    int? _selectedRoleId = user?.rolesId ?? 2;
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
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter a phone number';
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter an adresse'
                        : null,
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['active', 'inactive'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a status';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  FutureBuilder<List<Role>>(
                    future: _rolesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Error loading roles: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No roles available'),
                        );
                      }

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<int>(
                            value: _selectedRoleId,
                            decoration: const InputDecoration(labelText: 'Role'),
                            items: snapshot.data!.map((role) {
                              return DropdownMenuItem<int>(
                                value: role.id,
                                child: Text(role.nom),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedRoleId = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a role';
                              }
                              return null;
                            },
                          );
                        },
                      );
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
                      final newUser = User(
                        id: null,
                        rolesId: _selectedRoleId!,
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text.isNotEmpty
                            ? _passwordController.text
                            : null,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _selectedStatus!,
                      );
                      await _userService.addUser(newUser);
                      if (mounted) {
                        _showSnackBar('User added successfully!');
                        Navigator.pop(context);
                        _refreshUsers();
                      }
                    } else {
                      final updatedUser = User(
                        id: user.id,
                        rolesId: _selectedRoleId!,
                        nom: _nomController.text,
                        prenom: _prenomController.text,
                        email: _emailController.text,
                        password: _passwordController.text.isNotEmpty &&
                                _passwordController.text != user.password
                            ? _passwordController.text
                            : user.password,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        status: _selectedStatus!,
                        createdAt: user.createdAt,
                        updatedAt: user.updatedAt,
                        deletedAt: user.deletedAt,
                      );
                      await _userService.updateUser(updatedUser);
                      if (mounted) {
                        _showSnackBar('User updated successfully!');
                        Navigator.pop(context);
                        _refreshUsers();
                      }
                    }
                  } catch (e) {
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

    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    _passwordController.dispose();
  }

  Future<void> _confirmSuspend(int userId, String userName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Suspend'),
          content: Text('Are you sure you want to suspend $userName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Suspend'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _suspendUser(userId);
    }
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
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
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${userSnapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!userSnapshot.hasData ||
                      userSnapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('There is no data in database'));
                  }

                  if (_cachedUsers == null) {
                    _cachedUsers = List.from(userSnapshot.data!);
                  }

                  return FutureBuilder<List<Role>>(
                    future: _rolesFuture,
                    builder: (context, roleSnapshot) {
                      if (roleSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (roleSnapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error loading roles: ${roleSnapshot.error}',
                              style: const TextStyle(color: Colors.red)),
                        );
                      }

                      final roleMap = {
                        for (var r in roleSnapshot.data!) r.id: r.nom
                      };

                      final filteredUsers = _cachedUsers!.where((user) {
                        final searchLower = _searchQuery.toLowerCase();
                        return user.nom.toLowerCase().contains(searchLower) ||
                            user.prenom.toLowerCase().contains(searchLower) ||
                            user.email.toLowerCase().contains(searchLower) ||
                            (user.phone?.toLowerCase() ?? "").contains(searchLower) ||
                            (user.adresse?.toLowerCase() ?? "").contains(searchLower) ||
                            (roleMap[user.rolesId]?.toLowerCase() ?? "")
                                .contains(searchLower) ||
                            user.status.toLowerCase().contains(searchLower);
                      }).toList();

                      _sortUsers(filteredUsers, roleMap);

                      if (filteredUsers.isEmpty) {
                        return const Center(
                            child: Text("No matching results"));
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          bool isMobile = constraints.maxWidth < 600;

                          if (isMobile) {
                            return SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: defaultPadding,
                                  showCheckboxColumn: false,
                                  columns: [
                                    DataColumn(label: _buildSortableColumn("Nom", "name")),
                                    DataColumn(label: _buildSortableColumn("Email", "email")),
                                    DataColumn(label: _buildSortableColumn("Phone", "phone")),
                                    DataColumn(label: _buildSortableColumn("Role", "role")),
                                    DataColumn(
                                      label: Text(
                                        "Actions", 
                                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                      ),
                                    ),
                                  ],
                                  rows: filteredUsers.map((user) {
                                    final rowColor =
                                        user.status.toLowerCase() == 'active'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1);
                                    return DataRow(
                                      color:
                                          MaterialStateProperty.all(rowColor),
                                      onSelectChanged: (_) => _showUserDetails(user, roleMap[user.rolesId] ?? "Unknown"),
                                      cells: [
                                        DataCell(Text("${user.nom} ${user.prenom}")),
                                        DataCell(Text(user.email)),
                                        DataCell(Text(user.phone ?? '')),
                                        DataCell(Text(roleMap[user.rolesId] ?? "Unknown")),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () =>
                                                    _showUserDialog(user: user),
                                              ),
                                              if (user.status.toLowerCase() == 'inactive')
                                                IconButton(
                                                  icon: const Icon(Icons.check_circle,
                                                      color: Colors.green),
                                                  tooltip: 'Activate User',
                                                  onPressed: () => _activateUser(user.id!),
                                                )
                                              else
                                                IconButton(
                                                  icon: const Icon(Icons.pause_circle,
                                                      color: Colors.orange),
                                                  tooltip: 'Suspend User',
                                                  onPressed: () => _confirmSuspend(
                                                      user.id!, "${user.nom} ${user.prenom}"),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _confirmDelete(user.id!),
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
                                columnSpacing: defaultPadding * 6,
                                showCheckboxColumn: false,
                                columns: [
                                  DataColumn(label: _buildSortableColumn("Nom", "name")),
                                  DataColumn(label: _buildSortableColumn("Email", "email")),
                                  DataColumn(label: _buildSortableColumn("Phone", "phone")),
                                  DataColumn(label: _buildSortableColumn("Role", "role")),
                                  DataColumn(
                                    label: Text(
                                      "Actions", 
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                    ),
                                  ),
                                ],
                                rows: filteredUsers.map((user) {
                                  final rowColor =
                                      user.status.toLowerCase() == 'active'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1);
                                  return DataRow(
                                    color: MaterialStateProperty.all(rowColor),
                                    onSelectChanged: (_) => _showUserDetails(user, roleMap[user.rolesId] ?? "Unknown"),
                                    cells: [
                                      DataCell(Text("${user.nom} ${user.prenom}")),
                                      DataCell(Text(user.email)),
                                      DataCell(Text(user.phone ?? '')),
                                      DataCell(Text(roleMap[user.rolesId] ?? "Unknown")),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () =>
                                                  _showUserDialog(user: user),
                                            ),
                                            if (user.status.toLowerCase() == 'inactive')
                                              IconButton(
                                                icon: const Icon(Icons.check_circle,
                                                    color: Colors.green),
                                                tooltip: 'Activate User',
                                                onPressed: () => _activateUser(user.id!),
                                              )
                                            else
                                              IconButton(
                                                icon: const Icon(Icons.cancel,
                                                    color: Colors.orange),
                                                tooltip: 'Suspend User',
                                                onPressed: () => _confirmSuspend(
                                                    user.id!, "${user.nom} ${user.prenom}"),
                                              ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _confirmDelete(user.id!),
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
