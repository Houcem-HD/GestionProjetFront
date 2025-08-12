import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import placeholder screens
import 'package:admin/screens/task_screen.dart';
import 'package:admin/screens/document_screen.dart';
import 'package:admin/screens/store_screen.dart';
import 'package:admin/screens/notification_screen.dart';
import 'package:admin/screens/profile_screen.dart';
import 'package:admin/screens/settings_screen.dart';
import 'package:admin/screens/projets/list_projects.dart';
import 'package:admin/screens/users/list_user.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuController = Provider.of<MenuAppController>(context, listen: false);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            iconData: Icons.dashboard_outlined,
            press: () {
              menuController.setCurrentPage(DashboardScreen());
            },
          ),
          DrawerListTile(
            title: "Liste des Projects",
            iconData: Icons.work_outline,
            press: () {
              menuController.setCurrentPage(ProjectScreen());
            },
          ),
          DrawerListTile(
            title: "Liste des utilisateurs",
            iconData: Icons.group_outlined,
            press: () {
              menuController.setCurrentPage(UserListScreen());
            },
          ),
          DrawerListTile(
            title: "Documents",
            iconData: Icons.description_outlined,
            press: () {
              menuController.setCurrentPage(DocumentScreen());
            },
          ),
          DrawerListTile(
            title: "Store",
            iconData: Icons.storefront_outlined,
            press: () {
              menuController.setCurrentPage(StoreScreen());
            },
          ),
          DrawerListTile(
            title: "Notification",
            iconData: Icons.notifications_outlined,
            press: () {
              menuController.setCurrentPage(NotificationScreen());
            },
          ),
          DrawerListTile(
            title: "Profile",
            iconData: Icons.person_outline,
            press: () {
              menuController.setCurrentPage(ProfileScreen());
            },
          ),
          DrawerListTile(
            title: "Paramétres",
            iconData: Icons.settings_outlined,
            press: () {
              menuController.setCurrentPage(SettingsScreen());
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.iconData,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(
        iconData,
        color: Colors.white54,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
