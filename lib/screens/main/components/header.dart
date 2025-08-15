import 'dart:convert';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';

class Header extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchClear;
  
  const Header({Key? key, this.onSearchChanged, this.onSearchClear}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Gestion des Projets",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),

        // Search icon + expandable bar
        if (_showSearch)
          Expanded(child: SearchField(
            onClose: () {
              setState(() => _showSearch = false);
              if (widget.onSearchClear != null) {
                widget.onSearchClear!();
              }
            },
            onSearchChanged: widget.onSearchChanged,
          ))
        else
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => _showSearch = true);
            },
          ),

        const ProfileCard(), // Logout button inside ProfileCard
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _userName = "Not Logged In";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/get_user_name'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        setState(() {
          _userName =
              "${userData['nom']} ${userData['prenom']}" ?? "Unknown User";
        });
      } else {
        setState(() {
          _userName = "Unauthorized";
        });
      }
    } catch (e) {
      setState(() {
        _userName = "Error";
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isAuthenticated');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(_userName, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String)? onSearchChanged;
  
  const SearchField({Key? key, required this.onClose, this.onSearchChanged}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Search users...",
              fillColor: Theme.of(context).cardColor,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        if (widget.onSearchChanged != null) {
                          widget.onSearchChanged!("");
                        }
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {}); // Update UI for clear button
              if (widget.onSearchChanged != null) {
                widget.onSearchChanged!(value);
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
