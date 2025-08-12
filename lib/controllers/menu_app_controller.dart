import 'package:flutter/material.dart';
import 'package:admin/screens/dashboard_screen.dart'; // Import DashboardScreen

class MenuAppController extends ChangeNotifier {
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
Widget _currentPage = DashboardScreen(); // Default to DashboardScreen

GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
Widget get currentPage => _currentPage;

void controlMenu() {
  if (!_scaffoldKey.currentState!.isDrawerOpen) {
    _scaffoldKey.currentState!.openDrawer();
  }
}

void setCurrentPage(Widget page) {
  _currentPage = page;
  notifyListeners();
}
}
