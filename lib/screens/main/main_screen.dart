import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
    key: context.read<MenuAppController>().scaffoldKey, // Assign scaffoldKey
    drawer: SideMenu(),
    body: SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            Expanded(
              child: SideMenu(),
            ),
          Expanded(
            flex: 5,
            child: Consumer<MenuAppController>(
              builder: (context, menuController, child) {
                return menuController.currentPage; // Display the current page
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
