import 'package:flutter/material.dart';
import 'package:admin/screens/main/components/header.dart';
import 'package:admin/controllers/theme_controller.dart'; // Added theme controller import
import 'package:provider/provider.dart'; // Added provider import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Removed constants.dart dependency
        child: Column(
          children: [
            Header(),
            const SizedBox(height: 16.0), // Removed constants.dart dependency
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0), // Using 16.0 as defaultPadding equivalent
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appearance",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ThemeController>(
                    builder: (context, themeController, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                themeController.isDarkMode 
                                    ? Icons.dark_mode 
                                    : Icons.light_mode,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Dark Mode",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Switch(
                            value: themeController.isDarkMode,
                            onChanged: (value) {
                              themeController.toggleTheme();
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0), // Using 16.0 as defaultPadding equivalent
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "General Settings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Additional settings will be available here.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
